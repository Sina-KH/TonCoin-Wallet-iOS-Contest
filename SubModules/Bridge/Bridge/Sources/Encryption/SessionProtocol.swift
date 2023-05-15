//
//  Encryption.swift
//  Bridge
//
//  Created by Sina on 5/11/23.
//

import Foundation
import Sodium

class SessionProtocol {
    
    static let sodium = Sodium()

    static func newKey() -> Box.KeyPair {
        return sodium.box.keyPair()!
    }

    static func sign(message: Bytes, recipientPublicKey: Box.PublicKey, privateKey: Box.SecretKey) -> Bytes? {
        var result = sodium.randomBytes.buf(length: 24)!
        let msg = Sodium().box.seal(message: message,
                                    recipientPublicKey: recipientPublicKey,
                                    senderSecretKey: privateKey,
                                    nonce: result)!
        result.append(contentsOf: msg)
        return result
    }

    static func decrypt(message: Bytes, senderPublicKey: Box.PublicKey, recipientSecretKey: Box.SecretKey) -> Bytes? {
        return sodium.box.open(authenticatedCipherText: Array(message[24...]),
                               senderPublicKey: senderPublicKey,
                               recipientSecretKey: recipientSecretKey,
                               nonce: Array(message[0..<24]))
    }
}
