//
//  Created by Anton Spivak
//


import Foundation
import TON3


public struct BOC: RawRepresentable, ExpressibleByStringLiteral {
    
    public static let zero = BOC(code: Data())
    
    /// hex string
    public var rawValue: String
    
    public var hex: String { rawValue }
    public var bytes: [UInt8] { [UInt8](hex: rawValue) }
    public var data: Data { Data(hex: rawValue) }
    
    /// - parameter rawValue: HEX string of comiled BOC code
    public init(
        rawValue: String
    ) {
        self.rawValue = rawValue
    }
    
    /// - parameter rawValue: HEX string of comiled BOC code
    public init(
        bytes: [UInt8]
    ) {
        self.rawValue = bytes.toHexString()
    }
    
    /// - parameter stringLiteral: HEX string of comiled BOC code
    public init(
        stringLiteral value: StringLiteralType
    ) {
        self.rawValue = value
    }
    
    /// - parameter code: Bytes buffer of compiled BOC code
    public init(
        code: Data
    ) {
        self.init(
            rawValue: code.toHexString().uppercased()
        )
    }
    
    /// - parameter key: user key
    /// - parameter localUserPassword: password to decrypt private key from `key`
    /// - returns: boc with sha256 signature signed with private user key
    public func signed(
        with signature: Data
    ) async throws -> BOC {
        let signed = try await TON3.createBOCWithSignature(
            data: data,
            signature: signature.bytes
        )
        
        return BOC(code: signed)
    }
    
    /// - returns: cells data without headers and etc
    public func rootCellDataIfAvailable(
    ) async throws -> Data {
        guard data.count > 0
        else {
            return Data()
        }
        
        let hex = try await TON3.getBOCRootCellData(
            data: data
        )
        
        return hex
    }
    
    /// - returns: raw signature of hex
//    public func signature(
//        with key: Key,
//        localUserPassword: Data
//    ) async throws -> Data {
//        let secretKey = try await key.decryptedSecretKey(password: localUserPassword)
//
//        guard let signature = GTTONKey.createSignature(with: Data(hex: rawValue), privateKey: secretKey)
//        else {
//            throw UndefinedError()
//        }
//
//        return signature
//    }
//
//    // MARK: Private API
//
//    /// - returns: signature parsed BOC hash of hex
//    private func hsignature(
//        with key: Key,
//        localUserPassword: Data
//    ) async throws -> Data {
//        let secretKey = try await key.decryptedSecretKey(password: localUserPassword)
//        let hash = try await TON3.createBOCHash(data: data)
//
//        guard let signature = GTTONKey.createSignature(with: hash, privateKey: secretKey)
//        else {
//            throw UndefinedError()
//        }
//
//        return signature
//    }
}

extension BOC: Codable {}
extension BOC: Hashable {}
