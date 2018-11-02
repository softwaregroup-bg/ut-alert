module.exports = function utAlert() {
    return {
        ports: [],
        modules: {
            alert: require('./api/sql')
        },
        validations: {
            alert: require('./validations')
        },
        error: require('./errors')
    };
};
