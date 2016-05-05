var path = require('path');
module.exports = {
    schema: [{path: path.join(__dirname, '/schema'), linkSP: true}],
    'queue.push.request.send': require('./hooks/queue.push').send,
    'queue.push.response.receive': require('./hooks/queue.push').receive,
    'queue.pop.request.send': require('./hooks/queue.pop').send,
    'queue.pop.response.receive': require('./hooks/queue.pop').receive
};
