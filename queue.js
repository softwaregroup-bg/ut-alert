(function() {
    "use strict";

    module.exports = function MessageQueue(bus) {
        this.bus = bus;
        this.cronMap = {};

    };
})();
