var path = require('path');
module.exports = {
    schema: [{path: path.join(__dirname, '/schema'), linkSP: true}],
    'systemMessage.add.request.send': require('./hooks/systemMessage.add').send,
    'systemMessage.add.response.receive': require('./hooks/systemMessage.add').receive,
    'queue.pop.request.send': require('./hooks/queue.pop').send,
    'queue.pop.response.receive': require('./hooks/queue.pop').receive
};
