module.exports = function validation() {
    return {
        'alert.queueOut.read': () => require('./queueOut/read'),
        'alert.queueOut.push': () => require('./queueOut/push'),
        'alert.queueOut.pop': () => require('./queueOut/pop')
    };
};
