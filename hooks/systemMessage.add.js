'use strict';

var path = require('path');
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

        var portOptions = this.bus.config.alert.ports[msg.port];

        if (!portOptions.channel) {
            let err = ConfigurationError('alert.configuration.missing.key');
            err.path = ['alert', 'ports', {type: 'key', any: true}, 'channel'];
            throw err;
        }

        msg.channel = portOptions.channel;

        try {
            var channelHook = require(path.join(__dirname, '..', 'channel', msg.channel));
        } catch (e) {
            if (e.code !== 'MODULE_NOT_FOUND') {
                throw e;
            }
            return msg;
        }
        if (typeof channelHook.send === 'function') {
            return channelHook.send.call(this, msg, $meta);
        }

        return msg;
    },
    receive: function(msg, $meta) {
        try {
            var channelHook = require(path.join(__dirname, '..', 'channel', msg.inserted.channel));
        } catch (e) {
            if (e.code !== 'MODULE_NOT_FOUND') {
                throw e;
            }
            return msg;
        }
        if (typeof channelHook.receive === 'function') {
            return channelHook.receive.call(this, msg, $meta);
        }
        return msg;
    }
};
