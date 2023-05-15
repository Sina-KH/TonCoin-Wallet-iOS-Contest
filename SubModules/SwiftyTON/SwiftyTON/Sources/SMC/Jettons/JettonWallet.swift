//
//  Created by Anton Spivak
//

import Foundation


public protocol JettonWallet {
    
    var contract: Contract { get }
    
    var balance: Currency { get }
    var owner: Address? { get }
    
    // MARK: Initialization
    
    init(
        contract: Contract
    ) async throws
    
    init(
        concreteAddress: ConcreteAddress
    ) async throws
    
    init(
        address: Address
    ) async throws
}
