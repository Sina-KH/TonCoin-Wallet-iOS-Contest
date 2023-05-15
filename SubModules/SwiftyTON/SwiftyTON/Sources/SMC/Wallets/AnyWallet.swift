//
//  Created by Anton Spivak
//

import Foundation

public struct AnyWallet: Wallet {
    
    private let wallet: Wallet
    
    public var contract: Contract {
        wallet.contract
    }
    
    public var publicKey: String {
        get async throws {
            try await wallet.publicKey
        }
    }
    
    public init?(
        contract: Contract
    ) {
        switch contract.kind {
        case .none, .uninitialized, .walletV1R1, .walletV1R2, .walletV1R3:
            return nil
        case .walletV2R1, .walletV2R2:
            guard let wallet = Wallet2(contract: contract)
            else {
                return nil
            }
            
            self.wallet = wallet
        case .walletV3R1, .walletV3R2:
            guard let wallet = Wallet3(contract: contract)
            else {
                return nil
            }
            
            self.wallet = wallet
        case .walletV4R1, .walletV4R2:
            guard let wallet = Wallet4(contract: contract)
            else {
                return nil
            }
            
            self.wallet = wallet
        }
    }
    
//    public func subsequentExternalMessage() async throws -> [UInt8] {
//        try await wallet.subsequentExternalMessage()
//    }
//    
//    public func subsequentExternalMessageInitialCondition(
//        key: Key
//    ) async throws -> Contract.InitialCondition {
//        try await wallet.subsequentExternalMessageInitialCondition(
//            key: key
//        )
//    }
}
