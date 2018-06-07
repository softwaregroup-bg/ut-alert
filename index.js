module.exports = function utUser() {
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