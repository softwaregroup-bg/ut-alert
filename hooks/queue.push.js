'use strict';

var path = require('path');
var when = require('when');
var findChannel = require('../helpers/findChannel');
var emailSerialize = require('../helpers/email/serialize');
var emailUnserialize = require('../helpers/email/unserialize');

module.exports = {
    send: function(msg, $meta) {
        msg.channel = findChannel.call(this, msg.port);
        if (msg.channel === 'email') {
            msg.content = emailSerialize.call(this, msg.content);
        }
        return msg;
    },
    receive: function(msg, $meta) {
        if (msg.channel === 'email') {
            msg.content = emailUnserialize.call(this, msg.content);
        }
        return msg;
    }
};
