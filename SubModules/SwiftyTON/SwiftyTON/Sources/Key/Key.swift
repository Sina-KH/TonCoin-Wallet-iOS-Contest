//
//  Created by Anton Spivak
//

import Foundation


public struct Key {
    
    public let publicKey: String
    public let encryptedSecretKey: Data
    
    public init(
        publicKey: String,
        encryptedSecretKey: Data
    ) throws {
        let bytes: [UInt8]
        switch publicKey.count {
        case 96, 72, 64:
            bytes = Data(hex: publicKey).bytes
        default:
            bytes = publicKey.bytes
        }
        
        switch bytes.count {
        case 48:
            // all good, base64 encoded public key with flags
            self.publicKey = publicKey
        case 36:
            // base 64 decoded key
            self.publicKey = Data(bytes).base64EncodedString()
        case 32:
            // key without hash and flags
            let flagged = [0x3e, 0xe6] + bytes
            let hash = Data(flagged).crc16ccitt()
            self.publicKey = Data(flagged + hash).base64EncodedString()
        default:
            throw KeyError.invalidPublicKey
        }
        
        self.encryptedSecretKey = encryptedSecretKey
    }
    
//    public static func create(
//        password: Data,
//        mnemonic: Data = Data()
//    ) async throws -> Key {
//        let encryptedKey = try await wrapper.createKeyWithUserPassword(password, mnemonicPassword: mnemonic)
//        return try Key(
//            publicKey: encryptedKey.publicKey,
//            encryptedSecretKey: encryptedKey.encryptedSecretKey
//        )
//    }
//
//    public static func `import`(
//        password: Data,
//        mnemonic: Data = Data(),
//        words: [String]
//    ) async throws -> Key {
//        let encryptedKey = try await wrapper.importKeyWithUserPassword(password, mnemonicPassword: mnemonic, words: words)
//        return try Key(
//            publicKey: encryptedKey.publicKey,
//            encryptedSecretKey: encryptedKey.encryptedSecretKey
//        )
//    }
//
//    /// - parameter password: user local password used when key was created
//    /// - returns: 24 words mnemonic passphrase
//    public func words(
//        password: Data
//    ) async throws -> [String] {
//        let words = try await wrapper.wordsForKey(
//            GTTONKey(publicKey: publicKey, encryptedSecretKey: encryptedSecretKey),
//            userPassword: password
//        )
//
//        return words
//    }
    
    /// - returns: 32 bytes public key without any flags
    public func deserializedPublicKey(
    ) throws -> Data {
        guard publicKey.count == 48
        else {
            throw KeyError.invalidPublicKey
        }
        
        let base64Unescaped = publicKey.base64URLUnescaped()
        guard let base64KeyData = Data(base64Encoded: base64Unescaped),
              base64KeyData.count == 36
        else {
            throw KeyError.invalidPublicKey
        }
        
        let hash = Data([base64KeyData[34], base64KeyData[35]])
        guard hash == base64KeyData[0..<34].crc16ccitt()
        else {
            throw KeyError.incorrectCRC16Hash
        }
        
        guard base64KeyData[0] == 0x3e
        else {
            throw KeyError.notPublicByte
        }
        
        guard base64KeyData[1] == 0xe6
        else {
            throw KeyError.notED25519Byte
        }
        
        return Data(base64KeyData[2..<34])
    }
    
    /// - parameter password: user local password used when key was created
    /// - returns: 64 bytes private key without any flags
//    public func decryptedSecretKey(
//        password: Data
//    ) async throws -> Data {
//        let decryptedSecretKey = try await wrapper.decryptedSecretKeyForKey(
//            GTTONKey(publicKey: publicKey, encryptedSecretKey: encryptedSecretKey),
//            userPassword: password
//        )
//        
//        return decryptedSecretKey
//    }
}

extension Key: Codable {}
extension Key: Hashable {}
extension Key: Equatable {}
