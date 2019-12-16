var joi = require('joi');

module.exports = {
    description: 'pop messages',
    params: joi.any(),
    result: joi.any()
};
