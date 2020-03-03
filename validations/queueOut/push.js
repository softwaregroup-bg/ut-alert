var joi = require('joi');

module.exports = {
    description: 'push messages',
    params: joi.any(),
    result: joi.any()
};
