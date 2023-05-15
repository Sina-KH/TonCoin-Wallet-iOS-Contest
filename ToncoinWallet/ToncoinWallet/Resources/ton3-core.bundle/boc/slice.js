"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.Slice = void 0;
const cell_1 = require("./cell");
const helpers_1 = require("../utils/helpers");
class Slice {
    constructor(bits, refs) {
        this._bits = bits;
        this._refs = refs;
    }
    get bits() {
        return Array.from(this._bits);
    }
    get refs() {
        return Array.from(this._refs);
    }
    skip(size) {
        if (this._bits.length < size) {
            throw new Error('Slice: skip bits overflow.');
        }
        this._bits.splice(0, size);
        return this;
    }
    skipDict() {
        this.loadDict();
        return this;
    }
    loadRef() {
        if (!this._refs.length) {
            throw new Error('Slice: refs overflow.');
        }
        return this._refs.shift();
    }
    preloadRef() {
        if (!this._refs.length) {
            throw new Error('Slice: refs overflow.');
        }
        return this._refs[0];
    }
    loadBit() {
        if (!this._bits.length) {
            throw new Error('Slice: bits overflow.');
        }
        return this._bits.shift();
    }
    preloadBit() {
        if (!this._bits.length) {
            throw new Error('Slice: bits overflow.');
        }
        return this._bits[0];
    }
    loadBits(size) {
        if (size < 0 || this._bits.length < size) {
            throw new Error('Slice: bits overflow.');
        }
        return this._bits.splice(0, size);
    }
    preloadBits(size) {
        if (size < 0 || this._bits.length < size) {
            throw new Error('Slice: bits overflow.');
        }
        return this._bits.slice(0, size);
    }
    loadInt(size) {
        const uint = this.loadUint(size);
        const int = 1 << (size - 1);
        return uint >= int ? (uint - (int * 2)) : uint;
    }
    preloadInt(size) {
        const uint = this.preloadUint(size);
        const int = 1 << (size - 1);
        return uint >= int ? (uint - (int * 2)) : uint;
    }
    loadUint(size) {
        const bits = this.loadBits(size);
        return bits.reverse().reduce((acc, bit, i) => (bit * (2 ** i) + acc), 0);
    }
    preloadUint(size) {
        const bits = this.preloadBits(size);
        return bits.reverse().reduce((acc, bit, i) => (bit * (2 ** i) + acc), 0);
    }
    loadBytes(size) {
        const bits = this.loadBits(size);
        return (0, helpers_1.bitsToBytes)(bits);
    }
    preloadBytes(size) {
        const bits = this.preloadBits(size);
        return (0, helpers_1.bitsToBytes)(bits);
    }
    loadString(size = null) {
        const bytes = size === null
            ? this.loadBytes(this._bits.length)
            : this.loadBytes(size);
        return (0, helpers_1.bytesToString)(bytes);
    }
    preloadString(size = null) {
        const bytes = size === null
            ? this.preloadBytes(this._bits.length)
            : this.preloadBytes(size);
        return (0, helpers_1.bytesToString)(bytes);
    }
    loadAddress() {
        const FLAG_ADDRESS_NO = [0, 0];
        const FLAG_ADDRESS = [1, 0];
        const flag = this.preloadBits(2);
        if (flag.every((bit, i) => bit === FLAG_ADDRESS_NO[i])) {
            return this.skip(2) && null;
        }
        if (flag.every((bit, i) => bit === FLAG_ADDRESS[i])) {
            const size = 2 + 1 + 8 + 256;
            const bits = this.preloadBits(size);
            const anycast = bits.splice(2, 1);
            const workchain = (0, helpers_1.bitsToInt8)(bits.splice(2, 8));
            const hash = (0, helpers_1.bitsToHex)(bits.splice(2, 256));
            const raw = `${workchain}:${hash}`;
            return this.skip(size) && raw;
        }
        throw new Error('Slice: bad address flag bits.');
    }
    preloadAddress() {
        const FLAG_ADDRESS_NO = [0, 0];
        const FLAG_ADDRESS = [1, 0];
        const flag = this.preloadBits(2);
        if (flag.every((bit, i) => bit === FLAG_ADDRESS_NO[i])) {
            return null;
        }
        if (flag.every((bit, i) => bit === FLAG_ADDRESS[i])) {
            const size = 2 + 1 + 8 + 256;
            const bits = this.preloadBits(size);
            const anycast = bits.splice(2, 1);
            const workchain = (0, helpers_1.bitsToInt8)(bits.splice(2, 8));
            const hash = (0, helpers_1.bitsToHex)(bits.splice(2, 256));
            const raw = `${workchain}:${hash}`;
            return raw;
        }
        throw new Error('Slice: bad address flag bits.');
    }
    loadCoins() {
        const length = this.preloadUint(4);
        if (length === 0) {
            return this.skip(4) && 0;
        }
        const size = 4 + (length * 8);
        const bits = this.preloadBits(size);
        const hex = `0x${(0, helpers_1.bitsToHex)(bits.splice(4))}`;
        return this.skip(size) && Number(hex);
    }
    preloadCoins() {
        const length = this.preloadUint(4);
        if (length === 0) {
            return 0;
        }
        const size = 4 + (length * 8);
        const bits = this.preloadBits(size);
        const hex = `0x${(0, helpers_1.bitsToHex)(bits.splice(4))}`;
        return Number(hex);
    }
    loadDict() {
        const isEmpty = this.preloadBit() === 0;
        if (isEmpty) {
            this.skip(1);
            return null;
        }
        return new cell_1.Cell([this.loadBit()], [this.loadRef()], false);
    }
    preloadDict() {
        const isEmpty = this.preloadBit() === 0;
        if (isEmpty) {
            return null;
        }
        return new cell_1.Cell([this.preloadBit()], [this.preloadRef()], false);
    }
    static parse(cell) {
        return new Slice(cell.bits, cell.refs);
    }
}
exports.Slice = Slice;
