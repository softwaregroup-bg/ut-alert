var path = require('path');
var lodashTemplate = require('lodash.template');
var errors = require('./errors');
var findChannel = require('./helpers/findChannel');
module.exports = {
    schema: [{path: path.join(__dirname, '/schema'), linkSP: true}],
    'queueOut.push.request.send': require('./hooks/queueOut.push').send,
    'queueOut.push.response.receive': require('./hooks/queueOut.push').receive,
    'queueOut.pop.request.send': require('./hooks/queueOut.pop').send,
    'queueOut.pop.response.receive': require('./hooks/queueOut.pop').receive,
    'queueIn.pop.request.send': require('./hooks/queueIn.pop').send,
    'queueIn.pop.response.receive': require('./hooks/queueIn.pop').receive,
    'message.send': function(msg, $meta) {
        var bus = this.bus;
        var languageCode = msg.languageCode;
        if (!languageCode) {
            languageCode = $meta.language && $meta.language.iso2Code || null;
            if (!languageCode) {
                languageCode = bus.config.defaultLanguage;
                if (!languageCode) {
                    throw errors['alert.templateNotFound']({helperMessage: 'Language code is not specified'});
                }
            }
        }
        var channel = findChannel.call(this, msg.port);
        return bus.importMethod('alert.template.fetch')({
            channel: channel,
            name: msg.template,
            languageCode: languageCode
        }).then(function(response) {
            if (Array.isArray(response.templates) && response.templates.length > 0) {
                return response.templates;
            }
            if (bus.config.defaultLanguage && languageCode !== bus.config.defaultLanguage) {
                return bus.importMethod('alert.template.fetch')({
                    channel: channel,
                    name: msg.template,
                    languageCode: bus.config.defaultLanguage
                }).then(function(response) {
                    if (Array.isArray(response.templates) && response.templates.length > 0) {
                        return response.templates;
                    }
                    throw errors['alert.templateNotFound']({
                        helperMessage: 'No template found in database',
                        matching: {
                            channel: channel,
                            name: msg.template,
                            languageCode: languageCode
                        }
                    });
                });
            }
            throw errors['alert.templateNotFound']({
                helperMessage: 'No template found in database',
                matching: {
                    channel: channel,
                    name: msg.template,
                    languageCode: languageCode
                }
            });
        }).then(function(templates) {
            var templateMap = {};
            var content;
            templates.forEach(function(template) {
                templateMap[template.type] = template;
            });
            // TODO: Find a better way to generate a content without iteration by channels.
            // TODO: SMS channel content is just a string.
            // TODO: Email channel content is an object containing properties "subject" and at least one of "text" or "html".
            // TODO: Perhaps automate the properties generation with special "root" (for SMS channel) and then validate properties through alert.queueOut.push.
            // TODO: e.g. email: /subject = emailSubjectTemplate; email: /html = emailHtmlTemplate; sms: / = smsTemplate
            if (channel === 'sms') {
                if (!templateMap.hasOwnProperty('smsTemplate')) {
                    throw errors['alert.templateNotFound'](
                        {helperMessage: `Unable to find entry to itemName corresponding to itemType "smsTemplate" for template "${msg.template}"`}
                    );
                }
                content = lodashTemplate(templateMap.smsTemplate.content)(msg.data || {});
            } else if (channel === 'email') {
                if (!templateMap.hasOwnProperty('emailSubjectTemplate')) {
                    throw errors['alert.templateNotFound'](
                        {helperMessage: `Unable to find entry to itemName corresponding to itemType "emailSubjectTemplate" for template "${msg.template}"`}
                    );
                }
                if (!templateMap.hasOwnProperty('emailTextTemplate') && !templateMap.hasOwnProperty('emailHtmlTemplate')) {
                    throw errors['alert.templateNotFound'](
                        {
                            helperMessage: `Unable to find entry to itemName corresponding to itemType "emailTextTemplate" or "emailHtmlTemplate" for template "${msg.template}"`
                        }
                    );
                }
                content = {
                    subject: lodashTemplate(templateMap.emailSubjectTemplate.content)(msg.data || {})
                };
                if (templateMap.hasOwnProperty('emailTextTemplate')) {
                    content.text = lodashTemplate(templateMap.emailTextTemplate.content)(msg.data || {});
                }
                if (templateMap.hasOwnProperty('emailHtmlTemplate')) {
                    content.html = lodashTemplate(templateMap.emailHtmlTemplate.content)(msg.data || {});
                }
            } else {
                throw errors['alert.templateNotFound']({helperMessage: `Channel "${channel}" is not supported, yet`});
            }
            msg.content = content;
            delete msg.template;
            delete msg.data;
            $meta.method = 'alert.queueOut.push';
            return bus.importMethod($meta.method)(msg, $meta);
        });
    }
};
