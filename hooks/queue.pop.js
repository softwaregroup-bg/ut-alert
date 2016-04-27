'use strict';

var path = require('path');
var when = require('when');
var ConfigurationError = require('ut-error').define('ConfigurationError');
var RequestFieldError = require('ut-error').define('alert.RequestFieldError');

module.exports = {
    send: function(msg, $meta) {
        if (!this.bus.config.alert || !this.bus.config.alert.ports) {
            let err = ConfigurationError('alert.configuration.missing.key');
            err.path = ['alert', 'ports'];
            throw err;
        }
        if (!this.bus.config.alert.ports[msg.port]) {
            let err = RequestFieldError('alert.field.value.invalid');
            err.field = 'port';
            err.value = msg.port;
            throw err;
        }

        return msg;
    },
    receive: function(msg, $meta) {
        var self = this;
        return when.map(msg.messages, function(message) {
            try {
                var channelHook = require(path.join(__dirname, '..', 'channel', message.channel));
            } catch (e) {
                if (e.code !== 'MODULE_NOT_FOUND') {
                    throw e;
                }
                return message;
            }
            if (typeof channelHook.receive === 'function') {
                return channelHook.receive.call(self, message, $meta);
            }
            return message;
        }).then(function(messages) {
            msg.messages = messages;
            return msg;
        });
    }
};
