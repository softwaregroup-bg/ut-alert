'use strict';

var lodashAssign = require('lodash.assign');

const commonNotificationObject = {
    port: 'push',
    languageCode: 1,
    priority: 1
};

// Helper methods, preparing preformatted messages,
// that can be sent to aler.message.send.

module.exports = {
    prepareNotificationOnlyObject: function(notification) {
        return lodashAssign(commonNotificationObject, {
            template: 'firebase.notificationOnly',
            payload: {
                notification: JSON.stringify(notification.firebase)
            }
        });
    },
    prepareNotificationWithDataObject: function(notification, data) {
        return lodashAssign(commonNotificationObject, {
            template: 'firebase.notificationWithData',
            payload: {
                notification: JSON.stringify(notification.firebase),
                data: JSON.stringify(data)
            }
        });
    },
    prepareDataOnlyObject: function(data) {
        return lodashAssign(commonNotificationObject, {
            template: 'firebase.dataOnly',
            payload: {
                data: JSON.stringify(data)
            }
        });
    },
    // Changes the template name, and appends the extra object.
    // It will be parsed and prepared before sending to Firebase.
    appendExtra: function(notificationObject, extra) {
        return lodashAssign(notificationObject, {
            template: notificationObject.template + 'HasExtra',
            extra: extra
        });
    }
};
