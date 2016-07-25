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
        name: 'alert.queue.notifyFailure',
        defaultMessage: 'ut-core alert.queue.notifyFailure error'
    },
    {
        name: 'alert.queue.notifyFailure.not',
        defaultMessage: 'ut-core alert.queue.notifyFailure.not error'
    },
    {
        name: 'alert.queue.notifyFailure.not.exists',
        defaultMessage: 'Message does not exists'
    },
    {
        name: 'alert.queue.notifyFailure.invalid',
        defaultMessage: 'ut-core alert.queue.notifyFailure.invalid error'
    },
    {
        name: 'alert.queue.notifyFailure.invalid.status',
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
        name: 'alert.queue.push',
        defaultMessage: 'ut-core alert.queue.push error'
    },
    {
        name: 'alert.queue.push.missingCreatorId',
        defaultMessage: 'Missing credentials'
    }
].reduce(function(prev, next) {
    var spec = next.name.split('.');
    var Ctor = create(spec.pop(), spec.join('.'), next.defaultMessage);
    prev[next.parent ? next.parent + '.' + next.name : next.name] = function(params) {
        return new Ctor({params: params});
    };
    return prev;
}, {});
