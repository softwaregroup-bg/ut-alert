const path = require('path');
const lodashTemplate = require('lodash.template');
const pushHelpers = require('../../helpers/push');

const methods = ({findChannel, deviceOSToProvider}) => ({
    schema: [{path: path.join(__dirname, '/schema'), linkSP: true}],
    cbcStable: ['recipient'],
    start: function() {
        Object.assign(this.errors, this.errors.fetchErrors('alert'));
    },
    'alert.queueOut.push.request.send': function(msg) {
        msg.channel = findChannel(this.errors, msg);
        if (msg.channel === 'email') {
            msg.content = JSON.stringify(msg.content);
        }
        return msg;
    },
    'alert.queueOut.push.response.receive': function(msg) {
        if (msg.channel === 'email') {
            msg.content = JSON.parse(msg.content);
        }
        return msg;
    },
    'alert.queueOut.pop.request.send': function(msg) {
        msg.channel = findChannel(this.errors, msg);
        return msg;
    },
    'alert.queueOut.pop.response.receive': function(msg) {
        if (msg.channel === 'email') {
            msg.content = JSON.parse(msg.content);
        }
        return msg;
    },
    'alert.queueIn.pop.request.send': function(msg) {
        msg.channel = findChannel(this.errors, msg);
        return msg;
    },
    'alert.queueIn.pop.response.receive': function(msg, $meta) {
        if (msg.channel === 'email') {
            msg.content = JSON.parse(msg.content);
        }
        return msg;
    },
    /**
     * Internal methods for handling success and failure of sending a push notification.
     * These are called either by the [alert.push.notification.send] or by a cron in the implementations
     * after the sending has finished and a response has been received by the provider.
     */
    'alert.push.notification.handleSuccess': function(msg, $meta) {
        const { message, sendResponse } = msg; // message is the inserted row of alert.queueOut.push
        const { actorId, installationId } = JSON.parse(message.recipient);
        const updatePushNotificationToken = (updatedPushNotificationToken, actorId, installationId) => this.bus.importMethod('user.device.update')({
            actorDevice: {
                actorId,
                installationId,
                pushNotificationToken: updatedPushNotificationToken
            }
        });
        const notifySuccess = () => this.bus.importMethod('alert.queueOut.notifySuccess')({
            messageId: message.id,
            refId: sendResponse.refId
        });
        if (sendResponse.updatedPushNotificationToken) {
            return updatePushNotificationToken(sendResponse.updatedPushNotificationToken, actorId, installationId)
                .then(notifySuccess);
        } else {
            return notifySuccess();
        }
    },
    'alert.push.notification.handleFailure': function(msg, $meta) {
        const { message, errorResponse } = msg; // message is the inserted row of alert.queueOut.push
        const { actorId, installationId } = JSON.parse(message.recipient);
        const removePushNotificationToken = (actorId, installationId) => this.bus.importMethod('user.device.update')({
            actorDevice: {
                actorId,
                installationId,
                pushNotificationToken: null
            }
        });
        const notifyFailure = () => this.bus.importMethod('alert.queueOut.notifyFailure')({
            messageId: message.id,
            errorMessage: (errorResponse && errorResponse.error && errorResponse.error.message) || 'Failed to send push notification.',
            errorCode: (errorResponse && errorResponse.error && errorResponse.error.code) || 'pushNotificationFailure'
        });
        if (errorResponse.removePushNotificationToken) {
            return removePushNotificationToken(actorId, installationId)
                .then(notifyFailure);
        } else {
            return notifyFailure();
        }
    },
    /**
     * Sends a push notification. Currently only Google Firebase is supported.
     * Sample msg: {
     *   immediate: boolean, (defaults to false),
     *   template: 'template.key',
     *   languageCode: 'en', -- optional, can be inferred by the actorId
     *   data: {
     *     foo: 'foo',
     *     bar: 'bar', ...
     *   }
     * }
     */
    'alert.push.notification.send': function(msg, $meta) {
        const actorId = msg.actorId;
        const userDeviceGetParams = {
            actorId,
            installationId: msg.installationId ? msg.installationId : null
        };
        const notification = {
            data: msg.data || {},
            template: msg.template,
            languageCode: msg.languageCode || null,
            // System info
            immediate: msg.immediate ? msg.immediate : false,
            providerAlertMessageSends: [] // "alert.message.send" msg objects for each supported provider
        };
        // When the user.device.get procedure returns - append the devices array to the notification object.
        const getDevices = (notification) => this.bus.importMethod('user.device.get')(userDeviceGetParams).then(response => {
            if (!notification.languageCode) {
                notification.languageCode = response.user.languageCode;
            }
            notification.devices = response.device.filter(device => {
                return device.pushNotificationToken !== null;
            });
            return notification;
        });
        const prepareAlertMessageSends = (notification) => {
            pushHelpers.distributeRecipients(notification, deviceOSToProvider);
            delete notification.devices;
            return notification;
        };
        const prepareAlertMessageSendPromises = (notification) => {
            const alertMessageSendPromises = [];
            notification.providerAlertMessageSends.forEach(alertMessageSend => {
                if (notification.immediate) {
                    alertMessageSend.statusName = 'PROCESSING';
                }
                delete alertMessageSend.immediate;
                $meta.method = 'alert.message.send';
                alertMessageSendPromises.push(this.config[$meta.method](alertMessageSend, $meta));
            });
            return Promise.all(alertMessageSendPromises);
        };
        const handleAlertMessageSendResponse = (response) => {
            // This is the "default" behavior, the messages are queued and awaiting to be processed.
            if (!response.length) {
                return response;
            }
            return pushHelpers.handleImmediatePushNotificationSend(response, this);
        };
        return Promise.resolve(notification)
            .then(getDevices)
            .then(prepareAlertMessageSends)
            .then(prepareAlertMessageSendPromises)
            .then(handleAlertMessageSendResponse);
    },
    'alert.message.send': function(msg, $meta) {
        const bus = this.bus;
        let languageCode = msg.languageCode;
        if (!languageCode) {
            languageCode = ($meta.language && $meta.language.iso2Code) || null;
            if (!languageCode) {
                languageCode = bus.config.defaultLanguage;
                if (!languageCode) {
                    throw this.errors['alert.templateNotFound']({helperMessage: 'Language code is not specified'});
                }
            }
        }
        const channel = findChannel(this.errors, msg);
        return bus.importMethod('db/alert.template.fetch')({
            channel: channel,
            name: msg.template,
            languageCode: languageCode
        }).then(response => {
            return getTemplates(this.errors, bus, response, channel, languageCode, msg.template);
        }).then(templates => {
            msg.content = getContent(this.errors, templates, channel, msg.port, msg.template, msg.data);
            delete msg.template;
            delete msg.data;
            return bus.importMethod('db/alert.queueOut.push')(msg, $meta);
        });
    }
});

const getTemplates = (errors, bus, response, channel, languageCode, msgTemplate) => {
    if (Array.isArray(response.templates) && response.templates.length > 0) {
        return response.templates;
    }
    if (bus.config.defaultLanguage && languageCode !== bus.config.defaultLanguage) {
        return bus.importMethod('db/alert.template.fetch')({
            channel: channel,
            name: msgTemplate,
            languageCode: bus.config.defaultLanguage
        }).then(response => {
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

const getContent = (errors, templates, channel, port, msgTemplate, msgData) => {
    const templateMap = {};
    let content;
    templates.forEach(template => {
        templateMap[template.type] = template;
    });
    // TODO: Find a better way to generate a content without iteration by channels.
    // TODO: SMS channel content is just a string.
    // TODO: Email channel content is an object containing properties "subject" and at least one of "text" or "html".
    // TODO: Perhaps automate the properties generation with special "root" (for SMS channel) and then validate properties through alert.queueOut.push.
    // TODO: e.g. email: /subject = emailSubjectTemplate; email: /html = emailHtmlTemplate; sms: / = smsTemplate
    if (channel === 'sms') {
        if (!Object.prototype.hasOwnProperty.call(templateMap, 'smsTemplate')) {
            throw errors['alert.templateNotFound'](
                {helperMessage: `Unable to find entry to itemName corresponding to itemType "smsTemplate" for template "${msgTemplate}"`}
            );
        }
        content = lodashTemplate(templateMap.smsTemplate.content)(msgData || {});
    } else if (channel === 'email') {
        if (!Object.prototype.hasOwnProperty.call(templateMap, 'emailSubjectTemplate')) {
            throw errors['alert.templateNotFound'](
                {helperMessage: `Unable to find entry to itemName corresponding to itemType "emailSubjectTemplate" for template "${msgTemplate}"`}
            );
        }
        if (!Object.prototype.hasOwnProperty.call(templateMap, 'emailTextTemplate') && !Object.prototype.hasOwnProperty.call(templateMap, 'emailHtmlTemplate')) {
            throw errors['alert.templateNotFound'](
                {helperMessage: `Unable to find entry to itemName corresponding to itemType "emailTextTemplate" or "emailHtmlTemplate" for template "${msgTemplate}"`}
            );
        }
        content = {
            subject: lodashTemplate(templateMap.emailSubjectTemplate.content)(msgData || {})
        };
        if (Object.prototype.hasOwnProperty.call(templateMap, 'emailTextTemplate')) {
            content.text = lodashTemplate(templateMap.emailTextTemplate.content)(msgData || {});
        }
        if (Object.prototype.hasOwnProperty.call(templateMap, 'emailHtmlTemplate')) {
            content.html = lodashTemplate(templateMap.emailHtmlTemplate.content)(msgData || {});
        }
    } else if (channel === 'push') {
        const templateName = ['pushNotificationTemplate', port].join('.');
        if (!Object.prototype.hasOwnProperty.call(templateMap, templateName)) {
            throw errors['alert.templateNotFound']({helperMessage: `Unable to find entry to push notification template ${msgTemplate} for provider ${port}`});
        }
        content = lodashTemplate(templateMap[templateName].content)(msgData || {});
    } else {
        throw errors['alert.templateNotFound']({helperMessage: `Channel "${channel}" is not supported, yet`});
    }
    return content;
};

module.exports = function sql({config: {ports, deviceOSToProvider}} = {config: {}}) {
    return methods({
        deviceOSToProvider,
        findChannel: (errors, msg) => {
            if (!ports) throw errors['alert.portsNotFound']();
            if (!ports[msg.port]) throw errors['alert.portNotFound']({params: {port: msg.port}});
            const channel = ports[msg.port].channel;
            if (!channel) throw errors['alert.channelNotFound']({params: {port: msg.port}});
            return channel;
        }
    });
};
