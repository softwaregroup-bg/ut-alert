'use strict';

var ConfigurationError = require('ut-error').define('ConfigurationError');
var ChannelNotFound = require('ut-error').define('alert.channelNotFound', ConfigurationError);

module.exports = function(port) {
    if (!this.bus.config.alert || !this.bus.config.alert.ports) {
        let err = ConfigurationError('alert.configuration.missing.key');
        err.path = ['alert', 'ports'];
        throw err;
    }
    if (!this.bus.config.alert.ports[port]) {
        throw ChannelNotFound('alert.channel.for.port.not.found');
    }

    var portOptions = this.bus.config.alert.ports[port];

    if (!portOptions.channel) {
        let err = ConfigurationError('alert.configuration.missing.key');
        err.path = ['alert', 'ports', {type: 'key', any: true}, 'channel'];
        throw err;
    }

    return portOptions.channel;
};
