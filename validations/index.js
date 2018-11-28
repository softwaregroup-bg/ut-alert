module.exports = function validation() {
    return {
        'queueOut.read': () => require('./queueOut/read')
    };
};
