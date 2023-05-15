//
//  Created by Anton Spivak
//

import Foundation

import BigInt
import TON3

public extension Wallet {
    
    // MARK: - Variables
    
//    var seqno: Int32 {
//        get async throws {
//            guard contract.kind != nil
//            else {
//                return 0
//            }
//
//            let result = try await contract.execute(methodNamed: "seqno")
//            guard result.code == 0,
//                  let decimal = result.stack.last as? GTExecutionResultDecimal,
//                  let int = Int32(decimal.value)
//            else {
//                return 0
//            }
//
//            return int
//        }
//    }
    
    // MARK: - Initialization
    
//    init?(
//        concreteAddress: ConcreteAddress
//    ) async throws {
//        try await self.init(
//            address: concreteAddress.address
//        )
//    }
    
//    init?(
//        address: Address
//    ) async throws {
//        let contract = try await Contract(
//            address: address
//        )
//        
//        self.init(
//            contract: contract
//        )
//    }
    
    // MARK: Errors
    
    internal func checkInitialization(
    ) throws {
        guard contract.data.bytes.count == 0 || contract.kind == .uninitialized
        else {
            return
        }
        
        throw ContractError.unitialized
    }
    
    // Methods
    
//    func subsequentTransferMessage(
//        to concreteAddress: ConcreteAddress,
//        amount: Currency,
//        message: (body: Data?, initial: Data?),
//        key: Key,
//        passcode: Data
//    ) async throws -> Message {
//        let updated = try await Contract(address: contract.address)
//        guard updated.info.balance > amount
//        else {
//            throw ContractError.notEnaughtBalance
//        }
//
//        let subsequentExternalMessageBody = try await TON3.transfer(
//            external: try await subsequentExternalMessage(),
//            workchain: concreteAddress.address.workchain,
//            address: concreteAddress.address.hash,
//            amount: amount.value,
//            bounceable: concreteAddress.representation.flags.contains(.bounceable),
//            payload: message.body?.bytes,
//            state: message.initial?.bytes
//        )
//
//        var subsequentInitialCondition: Contract.InitialCondition?
//        if updated.kind == .uninitialized {
//            subsequentInitialCondition = try await subsequentExternalMessageInitialCondition(
//                key: key
//            )
//        }
//
//        let boc = BOC(bytes: subsequentExternalMessageBody)
//        return try await Message(
//            destination: contract.address,
//            initial: subsequentInitialCondition,
//            body: try await boc.signed(with: key, localUserPassword: passcode)
//        )
//    }
}
