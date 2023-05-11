//
//  PublicKeyUtils.swift
//  Bridge
//
//  Created by Sina on 5/11/23.
//

import Sodium

public extension Box.PublicKey {
    var toHex: String {
        return Sodium().utils.bin2hex(self)!
    }
}
