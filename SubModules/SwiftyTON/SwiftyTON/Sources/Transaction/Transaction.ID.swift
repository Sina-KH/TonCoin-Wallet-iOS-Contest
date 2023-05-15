//
//  Created by Anton Spivak
//

import Foundation

public extension Transaction {
    
    struct ID {
        
        public let logicalTime: Int64
        public let hash: Data
        
        public init(
            logicalTime: Int64,
            hash: Data
        ) {
            self.logicalTime = logicalTime
            self.hash = hash
        }
    }
}

extension Transaction.ID: Codable {}
extension Transaction.ID: Hashable {}
