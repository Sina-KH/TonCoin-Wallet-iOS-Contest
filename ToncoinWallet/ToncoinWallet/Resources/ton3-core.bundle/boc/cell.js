"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.Cell = void 0;
const helpers_1 = require("../utils/helpers");
const bit_1 = require("../types/bit");
const hash_1 = require("../utils/hash");
class Cell {
    constructor(bits = [], refs = [], exotic = false) {
        this._bits = bits;
        this._refs = refs;
        this._exotic = exotic;
    }
    get bits() {
        return Array.from(this._bits);
    }
    get refs() {
        return Array.from(this._refs);
    }
    get exotic() {
        return this._exotic;
    }
    get maxDepth() {
        const maxDepth = this.calculateMaxDepth();
        const value = Math.floor(maxDepth / 256) + (maxDepth % 256);
        const bits = value.toString(2).padStart(16, '0').split('').map(el => parseInt(el, 10));
        return bits;
    }
    get refsDescriptor() {
        const maxLevel = this.calculateMaxLevel();
        const value = this._refs.length + (Number(this._exotic) * 8) + (maxLevel * 32);
        const bits = value.toString(2).padStart(8, '0').split('').map(el => parseInt(el, 10));
        return bits;
    }
    get bitsDescriptor() {
        const value = Math.ceil(this._bits.length / 8) + Math.floor(this._bits.length / 8);
        const bits = value.toString(2).padStart(8, '0').split('').map(el => parseInt(el, 10));
        return bits;
    }
    get representation() {
        let representation = this.descriptors.concat(this.augmentedBits);
        this._refs.forEach((ref) => {
            const depth = ref.maxDepth;
            representation = representation.concat(depth);
        });
        this._refs.forEach((ref) => {
            const hex = ref.hash();
            const bits = (0, helpers_1.hexToBits)(hex);
            representation = representation.concat(bits);
        });
        return representation;
    }
    calculateMaxLevel() {
        if (!this.exotic) {
            return 0;
        }
        return 0;
    }
    calculateMaxDepth() {
        const maxDepth = this._refs.reduce((acc, cell) => {
            const depth = cell.calculateMaxDepth();
            return depth > acc ? depth : acc;
        }, 0);
        return this._refs.length
            ? maxDepth + 1
            : maxDepth;
    }
    get descriptors() {
        return this.refsDescriptor.concat(this.bitsDescriptor);
    }
    get augmentedBits() {
        return (0, bit_1.augment)(this._bits);
    }
    hash() {
        const bytes = (0, helpers_1.bitsToBytes)(this.representation);
        return (0, hash_1.sha256)(bytes);
    }
    data() {
        return (0, helpers_1.bitsToHex)(this._bits);
    }
    print(indent = '') {
        const bits = Array.from(this._bits);
        const areDivisible = bits.length % 4 === 0;
        const augmented = !areDivisible ? (0, bit_1.augment)(bits, 4) : bits;
        const fiftHex = `${(0, helpers_1.bitsToHex)(augmented).toUpperCase()}${!areDivisible ? '_' : ''}`;
        const output = [`${indent}x{${fiftHex}}\n`];
        this._refs.forEach(ref => output.push(ref.print(`${indent} `)));
        return output.join('');
    }
}
exports.Cell = Cell;
