var path = require('path');
module.exports = {
    schema: [{path: path.join(__dirname, '/schema'), linkSP: true}],
    'systemMessage.add.request.send': require('./hooks/systemMessage.add').send
};
