//
//  Created by Anton Spivak
//

import Foundation
import TON3

import BigInt

public struct Wallet2: Wallet {

    public let contract: Contract
    public let revision: Revision
    
    public var publicKey: String {
        get async throws {
            try checkInitialization()
            let bytes = try await contract.data.rootCellDataIfAvailable()
            return bytes[4..<36].toHexString()
        }
    }
    
    public init?(
        contract: Contract
    ) {
        switch contract.kind {
        case .walletV2R1:
            revision = .r1
        case .walletV2R2:
            revision = .r2
        default:
            return nil
        }
        
        self.contract = contract
    }
    
    /// - returns: Initial data for wallet V2
    public static func initial(
        revision: Revision = .r2,
        deserializedPublicKey: Data
    ) async throws -> Contract.InitialCondition {
        let builder = try await TON3.Builder()
        await builder.store(UInt32(0)) // seqno
        await builder.store(deserializedPublicKey.bytes)
        
        let boc = try await builder.boc()
        return Contract.InitialCondition(
            kind: revision.kind,
            data: Data(hex: boc)
        )
    }
//    
//    public func subsequentExternalMessage() async throws -> [UInt8] {
//        let seqno = (try? await seqno) ?? 0
//        
//        let builder = try await TON3.Builder()
//        await builder.store(UInt32(seqno))
//        await builder.store(UInt32(Date().timeIntervalSince1970 + 60))
//        await builder.store(UInt8(3)) // 3 default `send mode`
//        
//        let boc = try await builder.boc()
//        return [UInt8](hex: boc)
//    }
//    
//    public func subsequentExternalMessageInitialCondition(
//        key: Key
//    ) async throws -> Contract.InitialCondition {
//        try await Self.initial(
//            deserializedPublicKey: try key.deserializedPublicKey()
//        )
//    }
}

extension Wallet2: Codable {}
extension Wallet2: Hashable {}
