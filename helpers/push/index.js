// PRIVATE

/**
 * Creates a common alert.message.send msg.
 * Note that the data passed is equal for all providers.
 * If templates for any future provider require more fields in data, supply them too.
 * Templates that don't use all data variables will just ignore the extra ones.
 *
 * @param {String} operatingSystem - the OS of the device
 * @param {Object} notification
 * @param {Object} osToProviderMap - map between device OS and provider
 */
const buildCommonAlertMessageSendMsg = function(operatingSystem, notification, osToProviderMap) {
    const provider = osToProviderMap[operatingSystem];
    return {
        port: provider,
        languageCode: notification.languageCode,
        priority: 1,
        template: notification.template,
        data: notification.data || {},
        recipient: []
    };
};

// EXPORTED

/**
 * Fills recipients array for each provider.
 * @param {Object} notification
 */
const distributeRecipients = function(notification, osToProviderMap) {
    const providerAlertMessageSends = {};
    if (notification.devices.length) {
        notification.devices.forEach(device => {
            const deviceOS = device.deviceOS;
            if (!providerAlertMessageSends[deviceOS]) {
                providerAlertMessageSends[deviceOS] = buildCommonAlertMessageSendMsg(deviceOS, notification, osToProviderMap);
            }
            const providerAlertMessageSendMsg = providerAlertMessageSends[deviceOS];
            const recipient = JSON.stringify({
                actorId: device.actorId,
                installationId: device.installationId
            });
            providerAlertMessageSendMsg.recipient.push(recipient);
        });
    }
    const providerKeys = Object.keys(providerAlertMessageSends);
    providerKeys.forEach(providerKey => {
        notification.providerAlertMessageSends.push(providerAlertMessageSends[providerKey]);
    });
};

/**
 * Handles immediate sending of push notifications.
 * Flow:
 * 1. Checks for messages, that are inserted with manually set status "PROCESSING"
 * 2. Finds the pushNotificationToken for the message's recipient
 * 3. Prepares a simple message, that will be used by provider ports (currently only ut-port-firebase)
 * 4. Dispatches that message, and handles success/failure.
 *
 * @param {Array} response - array of providers, containing results of alert.message.send
 * @param {Object} context - the Port (bus, config...)
 */
const handleImmediatePushNotificationSend = function(response, port) {
    const insertedRowsForImmediateProcessing = [];
    response.forEach(providerResponse => {
        const inserted = providerResponse.inserted; // inserted - this is the result of alert.message.send
        inserted.length && inserted.forEach(insertedRow => {
            if (insertedRow.status === 'PROCESSING') {
                insertedRowsForImmediateProcessing.push(insertedRow);
            }
        });
    });
    // If there are no inserted rows with status "PROCESSING",
    // There is no need to handle immediate send. Just return the original response.
    if (!insertedRowsForImmediateProcessing.length) {
        return response;
    }
    // Initialize an array, that will containe send promises.
    const getRecipientPushNotificationToken = (insertedRow) => {
        const recipient = JSON.parse(insertedRow.recipient);
        return port.bus.importMethod('user.device.get')({
            actorId: recipient.actorId,
            installationId: recipient.installationId
        }).then(userDeviceResult => {
            if (!userDeviceResult.device.length || userDeviceResult.device.length > 1) {
                throw port.errors['alert.ambiguousResultForActorDevice']();
            }
            return userDeviceResult.device[0].pushNotificationToken;
        });
    };
    const preparePushMessage = (insertedRow) => (pushNotificationToken) => {
        return {
            id: insertedRow.id,
            content: insertedRow.content,
            pushNotificationToken
        };
    };
    const handleSuccess = (message) => (sendResponse) => {
        message.status = 'DELIVERED';
        return port.config['alert.push.notification.handleSuccess']({ message, sendResponse });
    };
    const handleFailure = (message) => (errorResponse) => {
        message.status = 'FAILED';
        return port.config['alert.push.notification.handleFailure']({ message, errorResponse });
    };
    // Define similar function for each provider.
    const dispatchToFirebase = (fcmMessage) => port.bus.importMethod('firebase.fcm.send')(fcmMessage);
    if (insertedRowsForImmediateProcessing.length) {
        const sendNotificationPromises = [];
        let dispatchToProvderPort = () => Promise.reject(port.errors['alert.providerNotImplemented']()); // Default - reject with no support.
        insertedRowsForImmediateProcessing.forEach(insertedRow => {
            if (insertedRow.port === 'firebase') {
                dispatchToProvderPort = dispatchToFirebase;
            }
            const promise = getRecipientPushNotificationToken(insertedRow)
                .then(preparePushMessage(insertedRow))
                .then(dispatchToProvderPort)
                .then(handleSuccess(insertedRow))
                .catch(handleFailure(insertedRow));
            sendNotificationPromises.push(promise);
        });
        return Promise.all(sendNotificationPromises).then(() => response);
    } else {
        return response;
    }
};

module.exports = {
    distributeRecipients,
    handleImmediatePushNotificationSend
};
