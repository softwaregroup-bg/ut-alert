'use strict';

var lodash = require('lodash');
var EventEmitter = require('events').EventEmitter;
var db = require('../../config/sequelize');
var Promise = db.sequelize.Promise;

/**
 * Simple CronJob implementation. Given an interval and callback, it executes the callback at regular interval.
 * Following notes describe why not to use other libraries:
 * 1. We need to execute jobs immediately at server start and then at regular intervals.
 * 2. Once interval is passed and job become working, we need to wait the job to complete all asynchronous tasks.
 * 3. Job declare completion of the task using Promise.
 * 4. Promise used must be sequelize Promise implementation in this project.
 *
 * The job has three states:
 * 1. Declared - Someone called "new CronJob()", but didn't call "run", yet.
 * 2. Running - Callback has been called and not completed, yet (probably doing something async).
 * 3. Waiting - Last call of the callback is completed and we are waiting timer to execute the next call.
 *
 * Scheme for work:
 * ooooo+++------+++------+++++------+-----+-----...
 * Where:
 * o - "declared" state, cronJob is created, but not run, yet.
 * + - "running", the callback function is called. If it returns a promise, that promise settle is awaited.
 * - - "awaiting", there is a timer for the next function.
 *
 * The time required to execute the callback does not affect the time between callbacks. If the time interval is 5
 * seconds, the CronJob wilL:
 * 1. Execute for example 3 seconds.
 * 2. Wait 5 seconds.
 * 3. Execute for example for 0.5 seconds.
 * 4. Wait 5 seconds.
 * 5. Executes for example for 1 minute.
 * 6. Wait 5 seconds.
 *
 * This means the job will never overlap with itself.
 * @constructor
 */
var CronJob = exports.CronJob = function CronJob(interval, callback) {
    if (!(this instanceof CronJob)) {
        return new CronJob(interval, callback);
    }
    this._interval = parseInt(interval);
    if (!isFinite(this._interval) || this._interval <= 0) {
        throw new TypeError('Expected "interval" to be positive integer value, defining interval in milliseconds.');
    }
    this._callback = callback;
    if (typeof this._callback !== 'function') {
        throw new TypeError('Expected "callback" to be function.');
    }
    this._timer = null;
    this._promise = null;
    this._repeat = false;
};

/**
 * Attempt to run the CronJob immediately and then continue running it repeatedly. If already running, wait current job
 * to finish to re-run it.
 * @return {CronJob}
 */
CronJob.prototype.run = function () {
    this._next();
    return this;
};

/**
 * Attempt to stop the cron job.
 * If the state is "waiting", this just stops the timer, returning the state of CronJob to "declared".
 * If the state is "declared", this does nothing.
 * If the state is "running", this awaits current execution to complete and then returns to "declared" state.
 * There is no way to stop already running execution, as the result of execution will be unknown.
 * @return Promise.<CronJob> - Once resolved, promise contains instance of self, guarantee "declared" state.
 */
CronJob.prototype.stop = Promise.method(function () {
    var self = this;
    if (self._timer) {
        clearTimeout(self._timer);
        self._timer = null;
    }
    if (self._promise) {
        self._awaitRun = true;
        return Promise.settle(self._promise).then(function () {
            return self;
        });
    }
    return self;
});

CronJob.prototype._run = function () {
    var self = this;
    self._promise = Promise.try(self._callback, [], self).finally(function () {
        self._promise = null;
        if (!self._awaitRun) {
            self._timer = setTimeout(self._next.bind(self), self._interval);
        } else {
            self._awaitRun = false;
        }
    });
};

CronJob.prototype._next = function () {
    var self = this;
    if (self._timer) {
        clearTimeout(self._timer);
        self._timer = null;
    }
    if (self._promise) {
        self._awaitRun = true;
        self._promise.finally(function () {
            if (self._timer) {
                clearTimeout(self._timer);
                self._timer = null;
            }
            self._run();
        });
    } else {
        self._run();
    }
};

CronJob.prototype.getInterval = function () {
    return this._interval;
};

CronJob.prototype.setInterval = function (nextInterval) {
    nextInterval = parseInt(nextInterval);
    if (!isFinite(nextInterval) || nextInterval < 0) {
        throw new TypeError('Expected "interval" to be positive integer value, defining interval in milliseconds.');
    }
    this._interval = nextInterval;
    return this;
};
