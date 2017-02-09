var path = require('path');
var lodashTemplate = require('lodash.template');
var lodashAssign = require('lodash.assign');
var errors = require('./errors');
var findChannel = require('./helpers/findChannel');
var when = require('when');
var pushFirebaseHelper = require('./helpers/push/firebase');

module.exports = {
    // init: function(b) {
    //     push.init(b);
    // },
    schema: [{path: path.join(__dirname, '/schema'), linkSP: true}],
    'queueOut.push.request.send': require('./hooks/queueOut.push').send,
    'queueOut.push.response.receive': require('./hooks/queueOut.push').receive,
    'queueOut.pop.request.send': require('./hooks/queueOut.pop').send,
    'queueOut.pop.response.receive': require('./hooks/queueOut.pop').receive,
    'queueIn.pop.request.send': require('./hooks/queueIn.pop').send,
    'queueIn.pop.response.receive': require('./hooks/queueIn.pop').receive,
    'push.notification.send': function(msg, $meta) {
        var notification = msg.notification || null;
        var data = msg.data || null;
        var firebaseExtra = msg.firebaseExtra || null; // collapse_key, time_to_live ...

        // The notification parameter contains generic notification info - title, body.. [badge, sound]
        // The data parameter contains app-specific data.

        return this.bus.importMethod('user.device.get')({
            actorId: msg.actorId
        })
        .then((result) => {
            var firebaseNotificationMessage;

            // Prepare the appropriate format of the notification for each of the supported providers.
            // Currenlty only Google Firebase is supported with their 3 types - data+notification | data | notification

            if (notification !== null && data !== null) {
                firebaseNotificationMessage = pushFirebaseHelper.prepareNotificationWithDataObject(notification, data);
            } else if (notification !== null && data === null) {
                firebaseNotificationMessage = pushFirebaseHelper.prepareNotificationOnlyObject(notification);
            } else if (notification === null && data !== null) {
                firebaseNotificationMessage = pushFirebaseHelper.prepareDataOnlyObject(data);
            } else {
                return when.reject('There are neither notification nor data present in the request for notification!');
            }
            if (firebaseExtra !== null) {
                firebaseNotificationMessage = pushFirebaseHelper.appendExtra(firebaseNotificationMessage, firebaseExtra);
            }

            var firebaseRecipients = []; // Declare other provider recipients arrays here.
            var alertMessageSendPromises = [];

            // Iterate over each of the actor's devices, and fill the appropriate recipient array.
            // Currently only Google Firebase (Android) is the supported recipient channel.

            result.device.forEach((device) => {
                let recipient = JSON.stringify({
                    actorId: msg.actorId,
                    installationId: device.installationId
                });
                if (device.deviceOS === 'android') {
                    firebaseRecipients.push(recipient);
                }
            });
            if (firebaseRecipients.length > 0) {
                let message = lodashAssign({}, firebaseNotificationMessage, {recipient: firebaseRecipients});
                alertMessageSendPromises.push(
                    this.bus.importMethod('alert.message.send')(message, $meta));
            }
            return when.all(alertMessageSendPromises);
        });
    },
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
                        {helperMessage: `Unable to find entry to itemName corresponding to itemType "emailTextTemplate" or "emailHtmlTemplate" for template "${msg.template}"`}
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
            } else if (channel === 'push') {
                if (!templateMap.hasOwnProperty('pushNotificationTemplate')) {
                    throw errors['alert.templateNotFound'](
                        {helperMessage: `Unable to find entry to itemName corresponding to itemType "pushNotificationTemplate" for template "${msg.template}"`}
                    );
                }
                content = lodashTemplate(templateMap.pushNotificationTemplate.content)(msg.payload || {});
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
