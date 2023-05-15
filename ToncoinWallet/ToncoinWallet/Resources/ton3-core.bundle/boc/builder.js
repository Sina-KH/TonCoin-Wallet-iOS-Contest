"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.Builder = void 0;
const cell_1 = require("./cell");
const slice_1 = require("./slice");
const helpers_1 = require("../utils/helpers");
class Builder {
    constructor(size = 1023) {
        this._size = size;
        this._bits = [];
        this._refs = [];
    }
    checkBitsOverflow(size) {
        if (size > this.remainder) {
            throw new Error(`Builder: bits overflow. Can't add ${size} bits. Only ${this.remainder} bits left.`);
        }
    }
    checkRefsOverflow(size) {
        if (size > (4 - this._refs.length)) {
            throw new Error(`Builder: refs overflow. Can't add ${size} refs. Only ${4 - this._refs.length} refs left.`);
        }
    }
    storeNumber(value, size) {
        const bits = [...Array(size)]
            .map((_el, i) => Number(((value >> BigInt(i)) & 1n) === 1n))
            .reverse();
        this.storeBits(bits);
        return this;
    }
    get size() {
        return this._size;
    }
    get bits() {
        return Array.from(this._bits);
    }
    get bytes() {
        return (0, helpers_1.bitsToBytes)(this._bits);
    }
    get refs() {
        return Array.from(this._refs);
    }
    get remainder() {
        return this._size - this._bits.length;
    }
    storeSlice(slice) {
        const { bits, refs } = slice;
        this.checkBitsOverflow(bits.length);
        this.checkRefsOverflow(refs.length);
        this.storeBits(bits);
        refs.forEach(ref => this.storeRef(ref));
        return this;
    }
    storeRef(ref) {
        this.checkRefsOverflow(1);
        this._refs.push(ref);
        return this;
    }
    storeBit(bit) {
        if (bit !== 0 && bit !== 1) {
            throw new Error('Builder: can\'t store bit, because it\'s type not Number or value doesn\'t equals 0 nor 1.');
        }
        this.checkBitsOverflow(1);
        this._bits.push(bit);
        return this;
    }
    storeBits(bits) {
        this.checkBitsOverflow(bits.length);
        this._bits = this._bits.concat(bits);
        return this;
    }
    storeInt(value, size) {
        const int = BigInt(value);
        const intBits = 1n << (BigInt(size) - 1n);
        if (int < -intBits || int >= intBits) {
            throw new Error('Builder: can\'t store an Int, because its value allocates more space than provided.');
        }
        this.storeNumber(int, size);
        return this;
    }
    storeUint(value, size) {
        const uint = BigInt(value);
        if (uint < 0 || uint >= (1n << BigInt(size))) {
            throw new Error('Builder: can\'t store an UInt, because its value allocates more space than provided.');
        }
        this.storeNumber(uint, size);
        return this;
    }
    storeVarInt(value, length) {
        const int = BigInt(value);
        const size = Math.ceil(Math.log2(length));
        const sizeBytes = Math.ceil((int.toString(2).length) / 8);
        const sizeBits = sizeBytes * 8;
        this.checkBitsOverflow(size + sizeBits);
        return int === 0n
            ? this.storeUint(0, size)
            : this.storeUint(sizeBytes, size).storeInt(value, sizeBits);
    }
    storeVarUint(value, length) {
        const uint = BigInt(value);
        const size = Math.ceil(Math.log2(length));
        const sizeBytes = Math.ceil((uint.toString(2).length) / 8);
        const sizeBits = sizeBytes * 8;
        this.checkBitsOverflow(size + sizeBits);
        return uint === 0n
            ? this.storeUint(0, size)
            : this.storeUint(sizeBytes, size).storeUint(value, sizeBits);
    }
    storeBytes(value) {
        this.checkBitsOverflow(value.length * 8);
        Uint8Array.from(value).forEach((byte) => this.storeUint(byte, 8));
        return this;
    }
    storeString(value) {
        const bytes = (0, helpers_1.stringToBytes)(value);
        this.storeBytes(bytes);
        return this;
    }
    storeAddress(address, workchain) {
        if (address === null) {
            this.storeBits([0, 0]);
            return this;
        }
        const anycast = 0;
        const addressBitsSize = 2 + 1 + 8 + 256;
        this.checkBitsOverflow(addressBitsSize);
        this.storeBits([1, 0]);
        this.storeUint(anycast, 1);
        this.storeInt(workchain, 8);
        this.storeBytes(address);
        return this;
    }
    storeCoins(coins) {
        if (coins < 0) {
            throw new Error('Builder: coins value can\'t be negative.');
        }
        const nano = BigInt(coins);
        this.storeVarUint(nano, 16);
        return this;
    }
    storeDict(hashmap) {
        const slice = slice_1.Slice.parse(hashmap.cell());
        this.storeSlice(slice);
        return this;
    }
    clone() {
        const data = new Builder(this._size);
        data.storeBits(this.bits);
        this.refs.forEach(ref => data.storeRef(ref));
        return data;
    }
    cell(isExotic = false) {
        const cell = new cell_1.Cell(this.bits, this.refs, isExotic);
        return cell;
    }
    fill(cell) {
        if (this._bits.length > 0 || this._refs.length > 0) {
            throw new Error('Builder: can\'t fill an Cell, because has an stored data.');
        }
        this._bits = Array.from(cell.bits);
        this._refs = Array.from(cell.refs);
        return this;
    }
}
exports.Builder = Builder;
