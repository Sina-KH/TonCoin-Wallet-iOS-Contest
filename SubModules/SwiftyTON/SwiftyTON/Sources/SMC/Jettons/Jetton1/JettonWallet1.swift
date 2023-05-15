//
//  Created by Anton Spivak
//

import Foundation

import TON3

//public struct JettonWallet1: JettonWallet {
//    
//    public let contract: Contract
//    
//    public let balance: Currency
//    public let owner: Address?
//    
//    public init(
//        contract: Contract
//    ) async throws {
//        guard contract.kind != .uninitialized
//        else {
//            self.contract = contract
//            self.balance = 0
//            self.owner = nil
//            
//            return
//        }
//        
//        let types = (
//            GTExecutionResultDecimal.self,
//            GTExecutionResultCell.self,
//            GTExecutionResultCell.self,
//            GTExecutionResultCell.self
//        )
//        
//        let stack = try await contract.execute(methodNamed: "get_wallet_data")
//        guard let stack = stack.map(to: types),
//              let balance = Int64(stack.0.value),
//              let rawAddress = try? await TON3.address(boc: stack.1.hex.bytes)
//        else {
//            throw ContractError.unknownContractType
//        }
//        
//        self.balance = Currency(balance)
//        self.owner = Address(rawValue: rawAddress)
//        self.contract = contract
//    }
//}
