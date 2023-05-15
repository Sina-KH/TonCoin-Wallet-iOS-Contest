//
//  PublicKeyUtils.swift
//  WalletCore
//
//  Created by Sina on 5/15/23.
//

import Foundation

public extension WalletPublicKey {
    var deserializedPublicKey: Data? {
        guard rawValue.count == 48
        else {
            return nil
        }
        
        let base64Unescaped = rawValue.base64URLUnescaped()
        guard let base64KeyData = Data(base64Encoded: base64Unescaped),
              base64KeyData.count == 36
        else {
            return nil
        }
        
        let hash = Data([base64KeyData[34], base64KeyData[35]])
        guard hash == base64KeyData[0..<34].crc16ccitt()
        else {
            return nil
        }
        
        guard base64KeyData[0] == 0x3e
        else {
            return nil
        }
        
        guard base64KeyData[1] == 0xe6
        else {
            return nil
        }
        
        return Data(base64KeyData[2..<34])
    }
}
