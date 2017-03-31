'use strict';

var when = require('when');
var lodashAssign = require('lodash.assign');
var request = require('requestretry');
var errors = require('../errors');

class FirebaseSender {
    constructor(bus, config) {
        this.bus = bus;
        this.config = config;
        this.firebaseErrors = {
            unavailable: 'Unavailable',
            notRegistered: 'NotRegistered',
            invalidRegistration: 'InvalidRegistration'
        };
        this.retryPolicy = {
            retryBackoffMultiplier: 2,
            maxRetryAttempts: 4,
            retryTimeout: 2000 // ms
        };
    }

    /**
     * MAIN Method.
     * Performs the actual sending of a push notification to Firebase.
     * @param {Object} message
     */
    sendNotification(message) {
        var builtNotificationObject = this.buildNotificationObject(message)
        .then((notificationObject) => {
            builtNotificationObject = notificationObject;
            return this.sendPushNotification(notificationObject);
        }).then((sendNotificationResponse) => {
            return this.parseResponse(sendNotificationResponse, message, builtNotificationObject);
        });
    }

    /**
     * Attaches the recipients and prepares the notification object (filling the required fields)
     * that is going to be JSON-serialized and sent to Firebase Cloud Messaging.
     * @param {Object} message
     * @return {Promise}
     */
    buildNotificationObject(message) {
        let recipient = JSON.parse(message.recipient);
        return this.bus.importMethod('user.device.get')({
            actorId: recipient.actorId,
            installationId: recipient.installationId
        }).then((response) => {
            let content = message.content;
            if (typeof message.content === 'string') {
                content = JSON.parse(message.content);
            }
            if (!response.device.length || response.device.length > 1) {
                return when.reject(errors['internal.ambiguousResultForActorDevice']);
            }
            let pushNotificationToken = response.device[0].pushNotificationToken;
            let payload = content.payload;
            // Add a UNIQUE key, required by the app. Use the message id from alert.messageOut.
            if (payload.hasOwnProperty('data') && payload.data.hasOwnProperty('notificationData')) {
                payload.data.notificationData.recordId = message.id;
            }
            let notificationObject = {
                to: pushNotificationToken// recipient.pushNotificationToken
            };
            lodashAssign(notificationObject, payload);
            if (content.hasOwnProperty('extra')) {
                let extra = content.extra;
                lodashAssign(notificationObject, extra);
            }
            return when.resolve(notificationObject);
        });
    }

    /**
     * Defines a retry strategy, used by the request. If FCM returns error, and the error is 'Unavailable', the request should be retried as per the documentation.
     * @return {boolean} - whether to retry or not the request
     */
    retryStrategy(error, response, body) {
        if (error !== null || !body.hasOwnProperty('multicast_id') || !body.hasOwnProperty('results')) {
            // The response is malformed - missing error, multicast_id, has no results.. Retry.
            return true;
        }
        if (body.hasOwnProperty('failure') && body.failure > 0) {
            // If the response is marked as failure by FCM, and the error is "Unavailable" - Retry.
            let result = body.results[0];
            let error = result.error;
            return (error === 'Unavailable'); // Could not bind this function to the class, that's why this constant is hardcoded here. Should be this.firebaseErrors.unavailable.
        }
        return false;
    };

    /**
     * Returns a "sending a notification" promise:
     * A promise that sends one push notification to one Android device. Resolves when the request is finished, rejects if the network fails or a bad request is sent..
     * @see https://firebase.google.com/docs/cloud-messaging/concept-options
     * @param {Object} notificationObject
     * @return {Promise}
     */
    sendPushNotification(notificationObject) {
        let url = this.config.baseUrl + this.config.endpoints.send;
        let requestOptions = {
            url: url,
            json: true,
            fullResponse: false,
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': 'key=' + this.config.apiKey
            },
            maxAttempts: this.retryPolicy.maxRetryAttempts,
            retryDelay: this.retryPolicy.retryTimeout,
            retryStrategy: this.retryStrategy,
            body: notificationObject // was JSON.stringify ..?
        };
        return request(requestOptions);
    };

    /**
     * Parses the response, received from FCM. Updates the actor's device token if needed.
     * Notifies successfull send or rejects if FCM marked the notification as failed.
     * @param {Object} response - the JSON-parsed response from FCM
     * @param {Object} message
     * @param {Object} notificationObject
     * @return {Promise}
     */
    parseResponse(response, message, notificationObject) {
        let result = response.results[0];
        let recipient = JSON.parse(message.recipient);
        if (response.failure > 0) {
            let fcmError = result.error;
            let rejectionError = errors.fcm['response.serviceUnavailable'];
            if (fcmError === this.firebaseErrors.invalidRegistration) {
                // TODO: invalid token, should remove that token?
                rejectionError = errors.fcm['response.invalidRegistration'];
            }
            if (fcmError === this.firebaseErrors.notRegistered) {
                // TODO: should remove that token?
                rejectionError = errors.fcm['response.notRegistered'];
            }
            // return when.reject(rejectionError);
            return this.notifyFailure(message, rejectionError);
        }

        if (result.hasOwnProperty('registration_id')) {
            let canonicalPushNotificationToken = result.registration_id;
            return this.bus.importMethod('user.device.update')({
                actorDevice: {
                    actorId: recipient.actorId,
                    installationId: recipient.installationId,
                    pushNotificationToken: canonicalPushNotificationToken
                }
            }).then(() => {
                return this.notifySuccess(message);
            });
        }
        return this.notifySuccess(message);
    }

    notifySuccess(message) {
        return this.bus.importMethod('alert.queueOut.notifySuccess')({
            messageId: message.id,
            refId: message.id
        });
    }

    notifyFailure(message, error) {
        return this.bus.importMethod('alert.queueOut.notifyFailure')({
            messageId: message.id,
            errorMessage: 'Failed to send',
            errorCode: 'firebase'
        });
    }

    // Static helper methods

    static buildRecipientsArray(devices, actorId) {
        var recipients = [];
        devices.forEach((device) => {
            let recipient = JSON.stringify({
                actorId: actorId,
                installationId: device.installationId
            });
            if (device.deviceOS === 'android') {
                recipients.push(recipient);
            }
        });
        return recipients;
    }
}

module.exports = FirebaseSender;
