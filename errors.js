var create = require('ut-error').define;
module.exports = [
    {
        name: 'alert',
        defaultMessage: 'ut-core alert error'
    },
    {
        name: 'alert.queue',
        defaultMessage: 'ut-core alert.queue error'
    },
    {
        name: 'alert.queueOut.notifyFailure',
        defaultMessage: 'ut-core alert.queueOut.notifyFailure error'
    },
    {
        name: 'alert.queueOut.notifyFailure.not',
        defaultMessage: 'ut-core alert.queueOut.notifyFailure.not error'
    },
    {
        name: 'alert.queueOut.notifyFailure.not.exists',
        defaultMessage: 'Message does not exists'
    },
    {
        name: 'alert.queueOut.notifyFailure.invalid',
        defaultMessage: 'ut-core alert.queueOut.notifyFailure.invalid error'
    },
    {
        name: 'alert.queueOut.notifyFailure.invalid.status',
        defaultMessage: 'Invalid message status'
    },
    {
        name: 'alert.message',
        defaultMessage: 'ut-core alert.message error'
    },
    {
        name: 'alert.message.not',
        defaultMessage: 'ut-core alert.message.not error'
    },
    {
        name: 'alert.message.not.exists',
        defaultMessage: 'Message does not exists'
    },
    {
        name: 'alert.message.invalid',
        defaultMessage: 'ut-core alert.message.invalid error'
    },
    {
        name: 'alert.message.invalid.status',
        defaultMessage: 'Invalid message status'
    },
    {
        name: 'alert.queueOut.push',
        defaultMessage: 'ut-core alert.queueOut.push error'
    },
    {
        name: 'alert.queueOut.push.missingCreatorId',
        defaultMessage: 'Missing credentials'
    },
    {
        name: 'alert.template',
        defaultMessage: 'ut-alert template error'
    },
    {
        name: 'alert.template.notFound',
        defaultMessage: 'Unable to find template matching parameters'
    }
].reduce(function(prev, next) {
    var spec = next.name.split('.');
    var Ctor = create(spec.pop(), spec.join('.'), next.defaultMessage);
    prev[next.name] = function(params) {
        return new Ctor({params: params});
    };
    return prev;
}, {});
