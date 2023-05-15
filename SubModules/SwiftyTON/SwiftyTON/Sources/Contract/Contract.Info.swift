//
//  Created by Anton Spivak
//

import Foundation

public extension Contract {
    
    struct Info {
        
        public let balance: Currency
        public let synchronizationDate: Date
        public let lastTransactionID: Transaction.ID?
        
        public init(
            balance: Currency,
            synchronizationDate: Date,
            lastTransactionID: Transaction.ID? = nil
        ) {
            self.balance = balance
            self.synchronizationDate = synchronizationDate
            self.lastTransactionID = lastTransactionID
        }
    }
}

extension Contract.Info: Codable {}
extension Contract.Info: Hashable {}
