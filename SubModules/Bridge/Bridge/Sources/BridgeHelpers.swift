//
//  BridgeHelpers.swift
//  Bridge
//
//  Created by Sina on 5/11/23.
//

import Foundation
import Sodium

public class BridgeHelpers {
    private init() {}
    
    public static func newKeyPair() -> Box.KeyPair {
        return Sodium().box.keyPair()!
    }

}
