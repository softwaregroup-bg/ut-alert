'use strict';

var joi = require('joi');

module.exports = {
    'push.notification.send': {
        description: 'Send push notifications to a number of devices, specified by an actorId',
        payload: joi.object().keys({
            actorId: joi.number().integer().required(),
            notification: joi.object().keys({
                firebase: joi.object().keys({
                    title: joi.string(),
                    body: joi.string()
                })
            }),
            data: joi.object()
        }).or('notification', 'data'),
        result: joi.any()
    }
};
