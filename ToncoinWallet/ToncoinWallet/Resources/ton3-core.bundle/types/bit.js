"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.rollback = exports.augment = void 0;
const augment = (bits, divider = 8) => {
    const amount = divider - (bits.length % divider);
    const overage = [...Array(amount)].map((_el, i) => (i === 0 ? 1 : 0));
    if (overage.length !== 0 && overage.length !== divider) {
        return bits.concat(overage);
    }
    return bits;
};
exports.augment = augment;
const rollback = (bits) => {
    const index = bits.slice(-7).reverse().indexOf(1);
    if (index === -1) {
        throw new Error('Incorrectly augmented bits.');
    }
    return bits.slice(0, -(index + 1));
};
exports.rollback = rollback;
