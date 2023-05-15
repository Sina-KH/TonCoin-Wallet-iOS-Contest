"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.bytesToBase64 = exports.base64ToBytes = exports.bytesToString = exports.stringToBytes = exports.sliceIntoChunks = exports.bytesToHex = exports.bytesToBits = exports.bytesCompare = exports.bytesToUint = exports.bitsToBytes = exports.bitsToInt8 = exports.bitsToHex = exports.hexToBytes = exports.hexToBits = exports.uintToHex = exports.int8ToUint8 = exports.uint8toInt8 = void 0;
const swiftyjs_1 = require("swiftyjs");
const isNodeEnv = typeof process === 'object' && process.title === 'node';
const uint8toInt8 = (uint8) => ((uint8 << 24) >> 24);
exports.uint8toInt8 = uint8toInt8;
const int8ToUint8 = (int8) => {
    const int = 1 << 7;
    return int8 >= int ? (int8 - (int * 2)) : int8;
};
exports.int8ToUint8 = int8ToUint8;
const uintToHex = (uint) => {
    const hex = `0${uint.toString(16)}`;
    return hex.slice(-(Math.floor(hex.length / 2) * 2));
};
exports.uintToHex = uintToHex;
const hexToBits = (hex) => hex.split('')
    .reduce((acc, val) => {
    const chunk = parseInt(val, 16)
        .toString(2)
        .padStart(4, '0')
        .split('')
        .map(bit => Number(bit));
    return acc.concat(chunk);
}, []);
exports.hexToBits = hexToBits;
const hexToBytes = (hex) => new Uint8Array(hex.match(/.{1,2}/g)
    .map(byte => parseInt(byte, 16)));
exports.hexToBytes = hexToBytes;
const bytesToUint = (bytes) => {
    const data = Array.from(bytes);
    const uint = data.reduce((acc, _el, i) => {
        acc *= 256;
        acc += bytes[i];
        return acc;
    }, 0);
    return uint;
};
exports.bytesToUint = bytesToUint;
const bytesCompare = (a, b) => {
    if (a.length !== b.length) {
        return false;
    }
    return Array.from(a).every((uint, i) => uint === b[i]);
};
exports.bytesCompare = bytesCompare;
const bytesToBits = (data) => {
    const bytes = new Uint8Array(data);
    return bytes.reduce((acc, uint) => {
        const chunk = uint.toString(2)
            .padStart(8, '0')
            .split('')
            .map(bit => Number(bit));
        return acc.concat(chunk);
    }, []);
};
exports.bytesToBits = bytesToBits;
const bitsToHex = (bits) => {
    const bitstring = bits.join('');
    const hex = (bitstring.match(/.{1,4}/g) || []).map(el => parseInt(el.padStart(4, '0'), 2).toString(16));
    return hex.join('');
};
exports.bitsToHex = bitsToHex;
const bitsToBytes = (bits) => {
    if (bits.length === 0) {
        return new Uint8Array();
    }
    return hexToBytes(bitsToHex(bits));
};
exports.bitsToBytes = bitsToBytes;
const bitsToInt8 = (bits) => uint8toInt8(bytesToUint(bitsToBytes(bits)));
exports.bitsToInt8 = bitsToInt8;
const bytesToHex = (bytes) => bytes.reduce((acc, uint) => `${acc}${uintToHex(uint)}`, '');
exports.bytesToHex = bytesToHex;
const bytesToString = (bytes) => {
    return (0, swiftyjs_1.TON3BytesToString)(bytes);
};
exports.bytesToString = bytesToString;
const stringToBytes = (value) => {
    return (0, swiftyjs_1.TON3StringToBytes)(value);
};
exports.stringToBytes = stringToBytes;
const bytesToBase64 = (data) => {
    return (0, swiftyjs_1.TON3BytesToBase64)(data);
};
exports.bytesToBase64 = bytesToBase64;
const base64ToBytes = (base64) => {
    return (0, swiftyjs_1.TON3Base64ToBytes)(base64);
};
exports.base64ToBytes = base64ToBytes;
const sliceIntoChunks = (arr, chunkSize) => {
    const res = [];
    for (let i = 0; i < arr.length; i += chunkSize) {
        const chunk = arr.slice(i, i + chunkSize);
        res.push(chunk);
    }
    return res;
};
exports.sliceIntoChunks = sliceIntoChunks;
