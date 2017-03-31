'use strict';

module.exports = {
    'internal.providerNotImplemented': {
        code: 'internal.providerNotImplemented',
        message: 'Provider not implemented.'
    },
    'internal.ambiguousResultForActorDevice': {
        code: 'internal.ambiguousResultForActorDevice',
        message: 'Zero or more than one device returned for an actorId & installationId!'
    },
    fcm: { // Firebase Cloud Messaging errors..
        'response.invalidRegistration': {
            code: 'fcm.response.invalidRegistration',
            message: 'FCM device pushNotificationToken (registrationId) problem: InvalidRegistration'
        },
        'response.notRegistered': {
            code: 'fcm.response.notRegistered',
            message: 'FCM device pushNotificationToken (registrationId) problem: NotRegistered'
        },
        'response.serviceUnavailable': {
            code: 'fcm.response.notRegistered',
            message: 'FCM Service is currently unavailable.'
        }
    }
};
