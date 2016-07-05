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
        return when.map(msg.inserted, function(inserted) {
            try {
                var channelHook = require(path.join(__dirname, '..', 'channel', inserted.channel));
            } catch (e) {
                if (e.code !== 'MODULE_NOT_FOUND') {
                    throw e;
                }
                return inserted;
            }
            if (typeof channelHook.receive === 'function') {
                return channelHook.receive.call(this, inserted, $meta);
            }
            return inserted;
        }).then(function(inserted) {
            msg.inserted = inserted;
            return msg;
        });
    }
};
