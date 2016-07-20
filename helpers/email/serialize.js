'use strict';

var RequestFieldError = require('ut-error').define('alert.RequestFieldError');

module.exports = function(msg) {
    if (typeof msg.content !== 'object') {
        let err = RequestFieldError('alert.field.value.invalid');
        err.field = 'content';
        err.value = msg.content;
        throw err;
    }
    if (typeof msg.content.subject !== 'string' || msg.content.subject.length <= 0) {
        let err = RequestFieldError('alert.field.value.invalid');
        err.field = 'content.subject';
        err.value = msg.content.subject;
        throw err;
    }
    let hasHtml = false;
    let hasText = false;
    let content = {
        subject: msg.content.subject
    };
    if (msg.content.html) {
        if (typeof msg.content.html !== 'string' || msg.content.html.length <= 0) {
            let err = RequestFieldError('alert.field.value.invalid');
            err.field = 'content.html';
            err.value = msg.content.subject;
            throw err;
        }
        hasHtml = true;
        content.html = msg.content.html;
    }
    if (msg.content.text) {
        if (typeof msg.content.text !== 'string' || msg.content.text.length <= 0) {
            let err = RequestFieldError('alert.field.value.invalid');
            err.field = 'content.html';
            err.value = msg.content.subject;
            throw err;
        }
        hasText = true;
        content.text = msg.content.text;
    }
    if (!hasHtml && !hasText) {
        let err = RequestFieldError('alert.field.missing');
        err.field = ['content.html', 'content.text'];
        err.requiredCount = 1;
        throw err;
    }

    msg.content = JSON.stringify(content);
    return msg;
};
