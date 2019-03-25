var joi = require('joi');

module.exports = {
    description: 'Generate and send message (email, sms) to recipient by a specified template',
    params: joi.object({
        port: joi.string().required(),
        template: joi.string().required(),
        recipient: joi.string().required(),
        channel: joi.string(),
        priority: joi.number(),
        messageInId: joi.number(),
        statusName: joi.string(),
        data: joi.object(),
        languageCode: joi.string()
    }),
    result: joi.any()
};
