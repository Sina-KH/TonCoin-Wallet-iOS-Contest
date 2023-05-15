//
//  Created by Anton Spivak
//

import Foundation


public protocol JettonMinter {
    
    var contract: Contract { get }
    
    var supply: Currency { get }
    var administrator: Address? { get }
    
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
    
    // MARK: Methods
    
    func jettonWallet(
        for address: Address
    ) async throws -> JettonWallet
}
