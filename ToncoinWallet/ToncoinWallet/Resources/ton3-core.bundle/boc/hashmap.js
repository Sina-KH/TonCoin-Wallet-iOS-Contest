"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.Hashmap = exports.HashmapE = void 0;
const builder_1 = require("./builder");
const slice_1 = require("./slice");
class Hashmap {
    constructor(keySize, options) {
        const { serializers = { key: (key) => key, value: (value) => value }, deserializers = { key: (key) => key, value: (value) => value } } = options || {};
        this.hashmap = new Map();
        this.keySize = keySize;
        this.serializeKey = serializers.key;
        this.serializeValue = serializers.value;
        this.deserializeKey = deserializers.key;
        this.deserializeValue = deserializers.value;
    }
    *[Symbol.iterator]() {
        for (const [k, v] of this.hashmap) {
            const key = this.deserializeKey(k.split('').map(b => Number(b)));
            const value = this.deserializeValue(v);
            yield [key, value];
        }
    }
    get(key) {
        const k = this.serializeKey(key).join('');
        const v = this.hashmap.get(k);
        return v !== undefined
            ? this.deserializeValue(v)
            : undefined;
    }
    has(key) {
        return this.get(key) !== undefined;
    }
    set(key, value) {
        const k = this.serializeKey(key).join('');
        const v = this.serializeValue(value);
        this.hashmap.set(k, v);
        return this;
    }
    add(key, value) {
        return !this.has(key)
            ? this.set(key, value)
            : this;
    }
    replace(key, value) {
        return this.has(key)
            ? this.set(key, value)
            : this;
    }
    getSet(key, value) {
        const prev = this.get(key);
        this.set(key, value);
        return prev;
    }
    getAdd(key, value) {
        const prev = this.get(key);
        this.add(key, value);
        return prev;
    }
    getReplace(key, value) {
        const prev = this.get(key);
        this.replace(key, value);
        return prev;
    }
    delete(key) {
        const k = this.serializeKey(key).join('');
        this.hashmap.delete(k);
        return this;
    }
    isEmpty() {
        return this.hashmap.size === 0;
    }
    forEach(callbackfn) {
        return [...this].forEach(([key, value]) => callbackfn(key, value));
    }
    getRaw(key) {
        return this.hashmap.get(key.join(''));
    }
    setRaw(key, value) {
        this.hashmap.set(key.join(''), value);
        return this;
    }
    sortHashmap() {
        const sorted = [...this.hashmap].reduce((acc, [bitstring, value]) => {
            const key = bitstring.split('').map(b => Number(b));
            const order = parseInt(bitstring, 2);
            const lt = acc.findIndex(el => order > el.order);
            const index = lt > -1 ? lt : acc.length;
            acc.splice(index, 0, { order, key, value });
            return acc;
        }, []);
        return sorted.map(el => [el.key, el.value]);
    }
    serialize() {
        const nodes = this.sortHashmap();
        if (nodes.length === 0) {
            throw new Error('Hashmap: can\'t be empty. It must contain at least 1 key-value pair.');
        }
        return Hashmap.serializeEdge(nodes);
    }
    static serializeEdge(nodes) {
        if (!nodes.length) {
            return new builder_1.Builder()
                .storeBit(0)
                .cell();
        }
        const edge = new builder_1.Builder();
        const label = this.serializeLabel(nodes);
        edge.storeBits(label);
        if (nodes.length === 1) {
            const leaf = this.serializeLeaf(nodes[0]);
            edge.storeSlice(slice_1.Slice.parse(leaf));
        }
        if (nodes.length > 1) {
            const [leftNodes, rightNodes] = this.serializeFork(nodes);
            const leftEdge = this.serializeEdge(leftNodes);
            edge.storeRef(leftEdge);
            if (rightNodes.length) {
                const rightEdge = this.serializeEdge(rightNodes);
                edge.storeRef(rightEdge);
            }
        }
        return edge.cell();
    }
    static serializeFork(nodes) {
        return nodes.reduce((acc, [key, value]) => {
            acc[key.shift()].push([key, value]);
            return acc;
        }, [[], []]);
    }
    static serializeLeaf(node) {
        return node[1];
    }
    static serializeLabel(nodes) {
        const [first] = nodes[0];
        const [last] = nodes[nodes.length - 1];
        const m = first.length;
        const sameBitsIndex = first.findIndex((bit, i) => bit !== last[i]);
        const sameBitsLength = sameBitsIndex === -1 ? first.length : sameBitsIndex;
        if (first[0] !== last[0] || m === 0) {
            return this.serializeLabelShort([]);
        }
        const label = first.slice(0, sameBitsLength);
        const repeated = label.join('').match(/(^0+)|(^1+)/)[0].split('').map(b => Number(b));
        const labelShort = this.serializeLabelShort(label);
        const labelLong = this.serializeLabelLong(label, m);
        const labelSame = nodes.length > 1 && repeated.length > 1
            ? this.serializeLabelSame(repeated, m)
            : null;
        const labels = [
            { bits: label.length, label: labelShort },
            { bits: label.length, label: labelLong },
            { bits: repeated.length, label: labelSame }
        ].filter(el => el.label !== null);
        labels.sort((a, b) => a.label.length - b.label.length);
        const choosen = labels[0];
        nodes.forEach(([key]) => key.splice(0, choosen.bits));
        return choosen.label;
    }
    static serializeLabelShort(bits) {
        const label = new builder_1.Builder();
        label.storeBit(0)
            .storeBits(bits.map(() => 1))
            .storeBit(0)
            .storeBits(bits);
        return label.bits;
    }
    static serializeLabelLong(bits, m) {
        const label = new builder_1.Builder();
        label.storeBits([1, 0])
            .storeUint(bits.length, Math.ceil(Math.log2(m + 1)))
            .storeBits(bits);
        return label.bits;
    }
    static serializeLabelSame(bits, m) {
        const label = new builder_1.Builder();
        label.storeBits([1, 1])
            .storeBit(bits[0])
            .storeUint(bits.length, Math.ceil(Math.log2(m + 1)));
        return label.bits;
    }
    static deserialize(keySize, slice, options) {
        if (slice.bits.length < 2) {
            throw new Error('Hashmap: can\'t be empty. It must contain at least 1 key-value pair.');
        }
        const hashmap = new Hashmap(keySize, options);
        const nodes = Hashmap.deserializeEdge(slice, keySize);
        for (let i = 0; i < nodes.length; i += 1) {
            const [key, value] = nodes[i];
            hashmap.setRaw(key, value);
        }
        return hashmap;
    }
    static deserializeEdge(edge, keySize, key = []) {
        const nodes = [];
        key.push(...this.deserializeLabel(edge, keySize - key.length));
        if (key.length === keySize) {
            const value = new builder_1.Builder().storeSlice(edge).cell();
            return nodes.concat([[key, value]]);
        }
        return edge.refs.reduce((acc, _r, i) => {
            const forkEdge = slice_1.Slice.parse(edge.loadRef());
            const forkKey = key.concat([i]);
            return acc.concat(this.deserializeEdge(forkEdge, keySize, forkKey));
        }, []);
    }
    static deserializeLabel(edge, m) {
        if (edge.loadBit() === 0) {
            return this.deserializeLabelShort(edge);
        }
        if (edge.loadBit() === 0) {
            return this.deserializeLabelLong(edge, m);
        }
        return this.deserializeLabelSame(edge, m);
    }
    static deserializeLabelShort(edge) {
        const length = edge.bits.findIndex(b => b === 0);
        return edge.skip(length + 1) && edge.loadBits(length);
    }
    static deserializeLabelLong(edge, m) {
        const length = edge.loadUint(Math.ceil(Math.log2(m + 1)));
        return edge.loadBits(length);
    }
    static deserializeLabelSame(edge, m) {
        const repeated = edge.loadBit();
        const length = edge.loadUint(Math.ceil(Math.log2(m + 1)));
        return [...Array(length)].map(() => repeated);
    }
    cell() {
        return this.serialize();
    }
    static parse(keySize, slice, options) {
        return this.deserialize(keySize, slice, options);
    }
}
exports.Hashmap = Hashmap;
class HashmapE extends Hashmap {
    constructor(keySize, options) {
        super(keySize, options);
    }
    serialize() {
        const nodes = this.sortHashmap();
        const result = new builder_1.Builder();
        if (!nodes.length) {
            return result
                .storeBit(0)
                .cell();
        }
        return result
            .storeBit(1)
            .storeRef(HashmapE.serializeEdge(nodes))
            .cell();
    }
    static deserialize(keySize, slice, options) {
        if (slice.bits.length !== 1) {
            throw new Error('HashmapE: bad hashmap size flag.');
        }
        if (slice.loadBit() === 0) {
            return new HashmapE(keySize, options);
        }
        const hashmap = new HashmapE(keySize, options);
        const nodes = Hashmap.deserializeEdge(slice, keySize);
        for (let i = 0; i < nodes.length; i += 1) {
            const [key, value] = nodes[i];
            hashmap.setRaw(key, value);
        }
        return hashmap;
    }
    static parse(keySize, slice, options) {
        return this.deserialize(keySize, slice, options);
    }
}
exports.HashmapE = HashmapE;
