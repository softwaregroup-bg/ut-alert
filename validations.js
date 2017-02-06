'use strict';

var joi = require('joi');

module.exports = {
    'push.notification.send': {
        description: 'Send push notifications to a number of devices',
        payload: joi.any(),
        result: joi.any()
    }
};
