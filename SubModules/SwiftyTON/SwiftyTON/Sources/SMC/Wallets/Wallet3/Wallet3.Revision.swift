//
//  Created by Anton Spivak
//

import Foundation

public extension Wallet3 {
    
    enum Revision {
        
        case r1
        case r2
    }
}

internal extension Wallet3.Revision {
    
    var kind: Contract.Kind {
        switch self {
        case .r1:
            return .walletV3R1
        case .r2:
            return .walletV3R2
        }
    }
}

extension Wallet3.Revision: Codable {}
extension Wallet3.Revision: Hashable {}
