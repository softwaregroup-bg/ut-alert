var create = require('ut-error').define;
module.exports = [
    {
        name: 'alert',
        defaultMessage: 'ut-core alert error',
        level: 'error'
    },
    {
        name: 'alert.queue',
        defaultMessage: 'ut-core alert.queue error',
        level: 'error'
    },
    {
        name: 'alert.queueOut.notifyFailure',
        defaultMessage: 'ut-core alert.queueOut.notifyFailure error',
        level: 'error'
    },
    {
        name: 'alert.queueOut.notifyFailure.not',
        defaultMessage: 'ut-core alert.queueOut.notifyFailure.not error',
        level: 'error'
    },
    {
        name: 'alert.queueOut.notifyFailure.not.exists',
        defaultMessage: 'Message does not exists',
        level: 'error'
    },
    {
        name: 'alert.queueOut.notifyFailure.invalid',
        defaultMessage: 'ut-core alert.queueOut.notifyFailure.invalid error',
        level: 'error'
    },
    {
        name: 'alert.queueOut.notifyFailure.invalid.status',
        defaultMessage: 'Invalid message status',
        level: 'error'
    },
    {
        name: 'alert.message',
        defaultMessage: 'ut-core alert.message error',
        level: 'error'
    },
    {
        name: 'alert.message.not',
        defaultMessage: 'ut-core alert.message.not error',
        level: 'error'
    },
    {
        name: 'alert.message.not.exists',
        defaultMessage: 'Message does not exists',
        level: 'error'
    },
    {
        name: 'alert.message.invalid',
        defaultMessage: 'ut-core alert.message.invalid error',
        level: 'error'
    },
    {
        name: 'alert.message.invalid.status',
        defaultMessage: 'Invalid message status',
        level: 'error'
    },
    {
        name: 'alert.queueOut.push',
        defaultMessage: 'ut-core alert.queueOut.push error',
        level: 'error'
    },
    {
        name: 'alert.queueOut.push.missingCreatorId',
        defaultMessage: 'Missing credentials',
        level: 'error'
    },
    {
        name: 'alert.template',
        defaultMessage: 'ut-alert template error',
        level: 'error'
    },
    {
        name: 'alert.template.notFound',
        defaultMessage: 'Unable to find template matching parameters',
        level: 'error'
    },
    {
        name: 'alert.field.value.invalid',
        defaultMessage: 'ut-alert invalid field error',
        level: 'error'
    },
    {
        name: 'alert.field.missing',
        defaultMessage: 'ut-alert missing field',
        level: 'error'
    }
].reduce(function(prev, next) {
    var spec = next.name.split('.');
    var Ctor = create(spec.pop(), spec.join('.'), next.defaultMessage);
    prev[next.name] = function(params) {
        return new Ctor({params: params});
    };
    return prev;
}, {});
