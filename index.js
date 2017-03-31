var path = require('path');
var lodashTemplate = require('lodash.template');
var lodashAssign = require('lodash.assign');
var errors = require('./errors');
var findChannel = require('./helpers/findChannel');

var FirebaseTemplateParser = require('./helpers/push/firebase/templateParser');
var FirebaseSender = require('./helpers/push/firebase/sender');

module.exports = {
    schema: [{path: path.join(__dirname, '/schema'), linkSP: true}],
    'queueOut.push.request.send': require('./hooks/queueOut.push').send,
    'queueOut.push.response.receive': require('./hooks/queueOut.push').receive,
    'queueOut.pop.request.send': require('./hooks/queueOut.pop').send,
    'queueOut.pop.response.receive': require('./hooks/queueOut.pop').receive,
    'queueIn.pop.request.send': require('./hooks/queueIn.pop').send,
    'queueIn.pop.response.receive': require('./hooks/queueIn.pop').receive,
    'push.notification.send': function(msg, $meta) {
        var userDeviceGetParameters = {
            actorId: msg.actorId
        };
        if (msg.hasOwnProperty('installationId')) {
            userDeviceGetParameters.installationId = msg.installationId;
        }
        return this.bus.importMethod('user.device.get')(userDeviceGetParameters)
        .then((result) => {
            // Prepare the appropriate format of the notification for each of the supported providers.
            // Currenlty only Google Firebase is supported with their 3 types - data+notification | data | notification

            var firebaseTemplateParser = new FirebaseTemplateParser(msg);
            var firebaseNotificationMessage = firebaseTemplateParser.prepareNotification();
            var firebaseRecipients = FirebaseSender.buildRecipientsArray(result.device, msg.actorId);

            var alertMessageSendPromises = []; // Array containing send promises for each of the Provider.
            if (firebaseRecipients.length > 0) {
                var message = lodashAssign({}, firebaseNotificationMessage, {recipient: firebaseRecipients});
                if (msg.immediate) {
                    // When the immediate parameter in the message is set to true,
                    // insert the message as 'PROCESSING', to avoid the Cron pulling them.
                    // Instead they will be processed immediately in the next then().
                    message.statusName = 'PROCESSING';
                }
                var $alertMessageSendMeta = lodashAssign({}, $meta, { method: 'alert.message.send' });
                alertMessageSendPromises.push(
                    this.bus.importMethod('alert.message.send')(message, $alertMessageSendMeta));
            }

            return Promise.all(alertMessageSendPromises);
        }).then((response) => {
            if (!response.length) {
                return response;
            }
            // Response contains array of inserted rows for each provieder, which are marked as PROCESSING.
            // That menas that they have to be processed immediately.
            var insertedRows = [];
            response.forEach(providerResponse => {
                const inserted = providerResponse.inserted;
                inserted.length && inserted.forEach(insertedRow => {
                    if (insertedRow.status === 'PROCESSING') {
                        insertedRows.push(insertedRow);
                    }
                });
            });
            if (!insertedRows.length) {
                return response;
            }

            // Initialize an array, that will containe send promises.
            // Also Instantiate a sender object for each supported provider.
            // Currently only Firebase is supported.
            var sendNotificationPromises = [];
            var firebaseSender = new FirebaseSender(this.bus, this.bus.config.push.firebase);

            insertedRows.length && insertedRows.forEach(insertedRow => {
                let content = JSON.parse(insertedRow.content);
                if (content.provider === 'firebase') {
                    sendNotificationPromises.push(firebaseSender.sendNotification(insertedRow));
                } // if (content.provider === 'apple) { ... }
            });

            if (sendNotificationPromises.length) {
                return Promise.all(sendNotificationPromises).then(() => {
                    return response;
                });
            } else {
                return response;
            }
        });
    },
    'message.send': function(msg, $meta) {
        var bus = this.bus;
        var languageCode = msg.languageCode;
        if (!languageCode) {
            languageCode = ($meta.language && $meta.language.iso2Code) || null;
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
            return getTemplates(bus, response, channel, languageCode, msg.template);
        }).then(function(templates) {
            msg.content = getContent(templates, channel, msg.template, msg.data, msg.payload);
            delete msg.template;
            delete msg.data;
            $meta.method = 'alert.queueOut.push';
            return bus.importMethod($meta.method)(msg, $meta);
        });
    }
};

// Helper functions

const getTemplates = (bus, response, channel, languageCode, msgTemplate) => {
    if (Array.isArray(response.templates) && response.templates.length > 0) {
        return response.templates;
    }
    if (bus.config.defaultLanguage && languageCode !== bus.config.defaultLanguage) {
        return bus.importMethod('alert.template.fetch')({
            channel: channel,
            name: msgTemplate,
            languageCode: bus.config.defaultLanguage
        }).then(function(response) {
            if (Array.isArray(response.templates) && response.templates.length > 0) {
                return response.templates;
            }
            throw errors['alert.templateNotFound']({
                helperMessage: 'No template found in database',
                matching: {
                    channel: channel,
                    name: msgTemplate,
                    languageCode: languageCode
                }
            });
        });
    }
    throw errors['alert.templateNotFound']({
        helperMessage: 'No template found in database',
        matching: {
            channel: channel,
            name: msgTemplate,
            languageCode: languageCode
        }
    });
};

const getContent = (templates, channel, msgTemplate, msgData, msgPayload) => {
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
                {helperMessage: `Unable to find entry to itemName corresponding to itemType "smsTemplate" for template "${msgTemplate}"`}
            );
        }
        content = lodashTemplate(templateMap.smsTemplate.content)(msgData || {});
    } else if (channel === 'email') {
        if (!templateMap.hasOwnProperty('emailSubjectTemplate')) {
            throw errors['alert.templateNotFound'](
                {helperMessage: `Unable to find entry to itemName corresponding to itemType "emailSubjectTemplate" for template "${msgTemplate}"`}
            );
        }
        if (!templateMap.hasOwnProperty('emailTextTemplate') && !templateMap.hasOwnProperty('emailHtmlTemplate')) {
            throw errors['alert.templateNotFound'](
                {helperMessage: `Unable to find entry to itemName corresponding to itemType "emailTextTemplate" or "emailHtmlTemplate" for template "${msgTemplate}"`}
            );
        }
        content = {
            subject: lodashTemplate(templateMap.emailSubjectTemplate.content)(msgData || {})
        };
        if (templateMap.hasOwnProperty('emailTextTemplate')) {
            content.text = lodashTemplate(templateMap.emailTextTemplate.content)(msgData || {});
        }
        if (templateMap.hasOwnProperty('emailHtmlTemplate')) {
            content.html = lodashTemplate(templateMap.emailHtmlTemplate.content)(msgData || {});
        }
    } else if (channel === 'push') {
        if (!templateMap.hasOwnProperty('pushNotificationTemplate')) {
            throw errors['alert.templateNotFound'](
                {helperMessage: `Unable to find entry to itemName corresponding to itemType "pushNotificationTemplate" for template "${msgTemplate}"`}
            );
        }
        content = lodashTemplate(templateMap.pushNotificationTemplate.content)(msgPayload || {});
    } else {
        throw errors['alert.templateNotFound']({helperMessage: `Channel "${channel}" is not supported, yet`});
    }
    return content;
};
