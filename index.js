module.exports = () => function utAlert() {
    return [
        function adapter() {
            return {
                modules: {
                    'db/alert': require('./api/sql/schema')
                },
                errors: require('./errors')
            };
        },
        function orchestrator() {
            return {
                ports: [
                    require('ut-dispatch-db')(['alert'])
                ]
            };
        },
        function gateway() {
            return {
                validations: {
                    alert: require('./validations')
                }
            };
        }
    ];
};
