module.exports = () => function utAlert() {
    return {
        adapter: () => [
            require('./api/sql/schema'),
            require('./api/sql/seed'),
            require('./errors')
        ],
        orchestrator: () => [
            require('ut-dispatch-db')(['alert'])
        ],
        gateway: () => [
            require('./validations')
        ]
    };
};
