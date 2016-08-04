var create = require('ut-error').define;
module.exports = [
    // alert
    {
        name: 'alert',
        defaultMessage: 'ut-alert error'
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
