module.exports = function error({utError: {defineError, getError, fetchErrors}}) {
    if (!getError('alert')) {
        let Alert = defineError('alert', undefined, 'ut-alert error');
        defineError('ambiguousResultForActorDevice', Alert, 'Zero or more than one device returned for an actorId & installationId!');
        defineError('channelNotFound', Alert, 'Missing utAlert.sql.ports.{port}.channel in the configuration');
        defineError('fieldMissing', Alert, 'Missing field');
        defineError('fieldValueInvalid', Alert, 'Invalid field value');
        defineError('messageInvalidStatus', Alert, 'Invalid message status');
        defineError('messageNotExists', Alert, 'Message does not exist');
        defineError('missingCreatorId', Alert, 'Missing credentials');
        defineError('portNotFound', Alert, 'Missing utAlert.sql.ports.{port} in the configuration');
        defineError('portsNotFound', Alert, 'Missing utAlert.sql.ports in the configuration');
        defineError('providerNotImplemented', Alert, 'Push notifications: Provider is not yet implemented');
        defineError('templateNotFound', Alert, 'Unable to find a template that matches the parameters');
    }
    return fetchErrors('alert');
};
