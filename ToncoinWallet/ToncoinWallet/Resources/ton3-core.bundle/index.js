"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getBOCRootCellData = exports.createBOCWithSignature = exports.createBOCHash = exports.transfer = exports.initial = exports.address = exports.Cell3 = exports.Builder3 = void 0;
const boc_1 = require("./boc");
const swiftyjs_1 = require("swiftyjs");
const helpers_1 = require("utils/helpers");
class Cell3 extends boc_1.Cell {
    constructor(boc) {
        const hex = (0, helpers_1.bytesToHex)(boc);
        let cell = boc_1.BOC.fromStandard(hex);
        super(cell.bits, cell.refs, cell.exotic);
    }
}
exports.Cell3 = Cell3;
class Builder3 extends boc_1.Builder {
    boc() {
        const cell = this.cell();
        return boc_1.BOC.toHexStandard(cell);
    }
}
exports.Builder3 = Builder3;
const address = function (boc) {
    const hex = (0, helpers_1.bytesToHex)(boc);
    const cell = boc_1.BOC.fromStandard(hex);
    const slice = boc_1.Slice.parse(cell);
    return slice.loadAddress();
};
exports.address = address;
const initial = function (code, data) {
    const builder = new boc_1.Builder();
    builder.storeBits([0, 0, 1]);
    builder.storeRef(new Cell3(code));
    if (data) {
        builder
            .storeBit(1)
            .storeRef(new Cell3(data));
    }
    else {
        builder.storeBit(0);
    }
    builder.storeBit(0);
    return boc_1.BOC.toHexStandard(builder.cell());
};
exports.initial = initial;
const transfer = function (message, workchain, address, amount, bounceable, payload, state) {
    const internalMessage = new MessageInternal({
        bounce: bounceable,
        srcAddress: null,
        destAddress: address,
        destWorkchain: workchain,
        value: amount
    }, internalMessagePayload(payload), internalMessageState(state));
    const externalMessage = new boc_1.Builder()
        .fill(boc_1.BOC.fromStandard((0, helpers_1.bytesToHex)(message)))
        .storeRef(internalMessage.cell());
    return boc_1.BOC.toHexStandard(externalMessage.cell());
};
exports.transfer = transfer;
const internalMessagePayload = function (payload) {
    if (!payload) {
        return null;
    }
    let cell;
    try {
        const hex = (0, helpers_1.bytesToHex)(payload);
        cell = boc_1.BOC.fromStandard(hex);
    }
    catch {
        const string = (0, swiftyjs_1.TON3BytesToString)(payload);
        const builder = new boc_1.Builder();
        if (string) {
            cell = builder
                .storeUint(0, 32)
                .storeString(string)
                .cell();
        }
        else {
            cell = builder
                .storeBytes(payload)
                .cell();
        }
    }
    return cell;
};
const internalMessageState = function (state) {
    if (!state) {
        return null;
    }
    const hex = (0, helpers_1.bytesToHex)(state);
    return boc_1.BOC.fromStandard(hex);
};
const createBOCHash = function (boc) {
    const cell = boc_1.BOC.fromStandard(boc);
    return cell.hash();
};
exports.createBOCHash = createBOCHash;
const createBOCWithSignature = function (boc, signature) {
    const cell = boc_1.BOC.fromStandard(boc);
    const signed = new boc_1.Builder()
        .storeBytes(signature)
        .storeSlice(boc_1.Slice.parse(cell))
        .cell();
    return boc_1.BOC.toHexStandard(signed);
};
exports.createBOCWithSignature = createBOCWithSignature;
const getBOCRootCellData = function (boc) {
    const cell = boc_1.BOC.fromStandard(boc);
    return cell.data();
};
exports.getBOCRootCellData = getBOCRootCellData;
class Message {
    constructor(header, body = null, state = null) {
        this.header = header;
        this.body = body;
        this.state = state;
    }
    cell() {
        const message = new boc_1.Builder()
            .storeSlice(boc_1.Slice.parse(this.header));
        if (this.state !== null) {
            message.storeBit(1);
            if (message.remainder >= this.state.bits.length + 1 && message.refs.length + this.state.refs.length <= 4) {
                message.storeBit(0).storeSlice(boc_1.Slice.parse(this.state));
            }
            else {
                message.storeBit(1).storeRef(this.state);
            }
        }
        else {
            message.storeBit(0);
        }
        if (this.body !== null) {
            if (message.remainder >= this.body.bits.length && message.refs.length + this.body.refs.length <= 4) {
                message.storeBit(0).storeSlice(boc_1.Slice.parse(this.body));
            }
            else {
                message.storeBit(1).storeRef(this.body);
            }
        }
        else {
            message.storeBit(0);
        }
        return message.cell();
    }
}
class MessageInternal extends Message {
    constructor(options, body, state) {
        const builder = new boc_1.Builder();
        const { ihrDisabled = true, bounce, bounced = false, srcAddress, srcWorkchain = 0, destAddress, destWorkchain = 0, value, ihrFee = 0, fwdFee = 0, createdLt = 0, createdAt = 0 } = options;
        const header = builder
            .storeBit(0)
            .storeInt(ihrDisabled ? -1 : 0, 1)
            .storeInt(bounce ? -1 : 0, 1)
            .storeInt(bounced ? -1 : 0, 1)
            .storeAddress(srcAddress, srcWorkchain)
            .storeAddress(destAddress, destWorkchain)
            .storeCoins(value)
            .storeBit(0)
            .storeCoins(ihrFee)
            .storeCoins(fwdFee)
            .storeUint(createdLt, 64)
            .storeUint(createdAt, 32)
            .cell();
        super(header, body, state);
    }
}
