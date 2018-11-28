module.exports = function validation() {
    return {
        'alert.queueOut.read': () => require('./queueOut/read')
    };
};
