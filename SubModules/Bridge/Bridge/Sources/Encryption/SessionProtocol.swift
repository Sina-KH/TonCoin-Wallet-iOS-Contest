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
        return Sodium().box.seal(message: message, recipientPublicKey: recipientPublicKey, senderSecretKey: privateKey, nonce: sodium.randomBytes.buf(length: 24)!)
    }

    static func decrypt(message: Bytes, keyPair: Box.KeyPair) -> Bytes? {
        return sodium.box.open(anonymousCipherText: message,
                               recipientPublicKey: keyPair.publicKey,
                               recipientSecretKey: keyPair.secretKey)
    }
}
