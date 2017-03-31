'use strict';

var lodashAssign = require('lodash.assign');

class FirebaseTemplateParser {
    constructor(msg) {
        // The notification parameter contains generic notification info - title, body.. [badge, sound]
        // The data parameter contains app-specific data.
        // The firebase extra can contain provider-specific info.
        this.notification = msg.notification || null;
        this.data = msg.data || null;
        this.extra = msg.firebaseExtra || null;

        this.prepareNotification = this.prepareNotification.bind(this);
        this.prepareNotificationOnlyObject = this.prepareNotificationOnlyObject.bind(this);
        this.prepareNotificationWithDataObject = this.prepareNotificationWithDataObject.bind(this);
        this.prepareDataOnlyObject = this.prepareDataOnlyObject.bind(this);
        this.appendExtra = this.appendExtra.bind(this);

        this.commonNotificationObject = {
            port: 'push',
            languageCode: 1,
            priority: 1
        };
    }

    prepareNotification() {
        let firebaseNotificationMessage;
        if (this.notification !== null && this.data !== null) {
            firebaseNotificationMessage = this.prepareNotificationWithDataObject();
        } else if (this.notification !== null && this.data === null) {
            firebaseNotificationMessage = this.prepareNotificationOnlyObject();
        } else if (this.notification === null && this.data !== null) {
            firebaseNotificationMessage = this.prepareDataOnlyObject();
        } else {
            // return Promise.reject('There are neither notification nor data present in the request for notification!');
            throw new Error('There are neither notification nor data present');
        }
        if (this.extra !== null) {
            firebaseNotificationMessage = this.appendExtra(firebaseNotificationMessage);
        }
        return firebaseNotificationMessage;
    }

    // Prepare templates

    prepareNotificationOnlyObject() {
        return lodashAssign(this.commonNotificationObject, {
            template: 'firebase.notificationOnly',
            payload: {
                notification: JSON.stringify(this.notification.firebase)
            }
        });
    }

    prepareNotificationWithDataObject() {
        return lodashAssign(this.commonNotificationObject, {
            template: 'firebase.notificationWithData',
            payload: {
                notification: JSON.stringify(this.notification.firebase),
                data: JSON.stringify(this.data)
            }
        });
    }

    prepareDataOnlyObject() {
        return lodashAssign(this.commonNotificationObject, {
            template: 'firebase.dataOnly',
            payload: {
                data: JSON.stringify(this.data)
            }
        });
    }

    appendExtra(notificationObject) {
        return lodashAssign(notificationObject, {
            template: notificationObject.template + 'HasExtra',
            extra: this.extra
        });
    }
}

module.exports = FirebaseTemplateParser;
