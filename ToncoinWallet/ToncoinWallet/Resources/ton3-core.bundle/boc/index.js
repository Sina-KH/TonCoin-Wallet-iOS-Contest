"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.Builder = exports.Slice = exports.HashmapE = exports.Hashmap = exports.Cell = exports.BOC = void 0;
const builder_1 = require("./builder");
Object.defineProperty(exports, "Builder", { enumerable: true, get: function () { return builder_1.Builder; } });
const slice_1 = require("./slice");
Object.defineProperty(exports, "Slice", { enumerable: true, get: function () { return slice_1.Slice; } });
const cell_1 = require("./cell");
Object.defineProperty(exports, "Cell", { enumerable: true, get: function () { return cell_1.Cell; } });
const hashmap_1 = require("./hashmap");
Object.defineProperty(exports, "Hashmap", { enumerable: true, get: function () { return hashmap_1.Hashmap; } });
Object.defineProperty(exports, "HashmapE", { enumerable: true, get: function () { return hashmap_1.HashmapE; } });
const helpers_1 = require("../utils/helpers");
const serializer_1 = require("./serializer");
class BOC {
    static isHex(data) {
        const re = /^[a-fA-F0-9]+$/;
        return typeof data === 'string' && re.test(data);
    }
    static isBase64(data) {
        const re = /^(?:[A-Za-z0-9+\/]{4})*(?:[A-Za-z0-9+\/]{2}==|[A-Za-z0-9+\/]{3}=)?$/;
        return typeof data === 'string' && re.test(data);
    }
    static isFift(data) {
        const re = /^x\{/;
        return typeof data === 'string' && re.test(data);
    }
    static isBytes(data) {
        return ArrayBuffer.isView(data);
    }
    static from(data) {
        if (BOC.isBytes(data)) {
            return (0, serializer_1.deserialize)(data);
        }
        const value = data.trim();
        if (BOC.isFift(value)) {
            return (0, serializer_1.deserializeFift)(value);
        }
        if (BOC.isHex(value)) {
            return (0, serializer_1.deserialize)((0, helpers_1.hexToBytes)(value));
        }
        if (BOC.isBase64(value)) {
            return (0, serializer_1.deserialize)((0, helpers_1.base64ToBytes)(value));
        }
        throw new Error('BOC: can\'t deserialize. Bad data.');
    }
    static fromStandard(data) {
        const cells = BOC.from(data);
        if (cells.length !== 1) {
            throw new Error(`BOC: standard BOC consists of only 1 root cell. Got ${cells.length}.`);
        }
        return cells[0];
    }
    static toBytes(cells, options) {
        if (cells.length === 0 || cells.length > 4) {
            throw new Error('BOC: root cells length must be from 1 to 4');
        }
        return (0, serializer_1.serialize)(cells, options);
    }
    static toBytesStandard(cell, options) {
        return BOC.toBytes([cell], options);
    }
    static toBase64(cells, options) {
        const bytes = BOC.toBytes(cells, options);
        return (0, helpers_1.bytesToBase64)(bytes);
    }
    static toBase64Standard(cell, options) {
        return BOC.toBase64([cell], options);
    }
    static toFiftHex(cells) {
        const fift = cells.map(cell => cell.print());
        return fift.join('\n');
    }
    static toFiftHexStandard(cell) {
        return BOC.toFiftHex([cell]);
    }
    static toHex(cells, options) {
        const bytes = BOC.toBytes(cells, options);
        return (0, helpers_1.bytesToHex)(bytes);
    }
    static toHexStandard(cell, options) {
        return BOC.toHex([cell], options);
    }
}
exports.BOC = BOC;
