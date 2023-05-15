"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.crc32cBytesLe = exports.crc16BytesBe = void 0;
const crc16 = (data) => {
    const POLY = 0x1021;
    const bytes = new Uint8Array(data);
    const result = bytes.reduce((acc, el) => {
        let crc = acc ^ (el << 8);
        new Array(8).fill(0).forEach(() => {
            crc = (crc & 0x8000) === 0x8000
                ? (crc << 1) ^ POLY
                : crc << 1;
        });
        return crc;
    }, 0);
    return (result & 0xffff);
};
const crc16BytesBe = (data) => {
    const crc = crc16(data);
    const buffer = new ArrayBuffer(2);
    const view = new DataView(buffer);
    view.setUint16(0, crc, false);
    return new Uint8Array(view.buffer, view.byteOffset, view.byteLength);
};
exports.crc16BytesBe = crc16BytesBe;
const crc32c = (data) => {
    const POLY = 0x82f63b78;
    const bytes = new Uint8Array(data);
    const result = [...Array(bytes.length)].reduce((acc, _el, i) => {
        let crc = i === 0 ? 0xffffffff ^ bytes[i] : acc ^ bytes[i];
        new Array(8).fill(0).forEach(() => {
            crc = crc & 1 ? (crc >>> 1) ^ POLY : crc >>> 1;
        });
        return crc;
    }, 0);
    return result ^ 0xffffffff;
};
const crc32cBytesLe = (data) => {
    const crc = crc32c(data);
    const buffer = new ArrayBuffer(4);
    const view = new DataView(buffer);
    view.setUint32(0, crc, true);
    return new Uint8Array(view.buffer, view.byteOffset, view.byteLength);
};
exports.crc32cBytesLe = crc32cBytesLe;
