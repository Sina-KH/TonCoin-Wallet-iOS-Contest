//
//  Created by Anton Spivak
//

import Foundation


public protocol Wallet {
    
    var contract: Contract { get }
    
//    var seqno: Int32 { get async throws }
    var publicKey: String { get async throws }
    
    init?(contract: Contract)
//    init?(concreteAddress: ConcreteAddress) async throws
//    init?(address: Address) async throws
    
    /// External message for next (pending) query
//    func subsequentExternalMessage() async throws -> [UInt8]
    
    /// Initial condition (state) for SMC
//    func subsequentExternalMessageInitialCondition(
//        key: Key
//    ) async throws -> Contract.InitialCondition
    
    /// External message initial data for next (pending) query, should be returned only
    /// - warning: Being cool if you will update contract before calling
//    func subsequentTransferMessage(
//        to concreteAddress: ConcreteAddress,
//        amount: Currency,
//        message: (body: Data?, initial: Data?),
//        key: Key,
//        passcode: Data
//    ) async throws -> Message
}
