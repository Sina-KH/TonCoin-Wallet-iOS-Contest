"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.sha512 = exports.sha256 = void 0;
const swiftyjs_1 = require("swiftyjs");
const sha256 = (bytes) => {
    return (0, swiftyjs_1.TON3SHA256)(bytes);
};
exports.sha256 = sha256;
const sha512 = (bytes) => {
    return (0, swiftyjs_1.TON3SHA512)(bytes);
};
exports.sha512 = sha512;
