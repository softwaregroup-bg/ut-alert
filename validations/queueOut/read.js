const joi = require('joi');

module.exports = {
    description: 'Get latest alert message generated for given recipient',
    params: joi.object({
        recipient: joi.string().required(),
        statusId: joi.string()
    }),
    result: joi.object().keys({
        message: joi.string()
    })
};
