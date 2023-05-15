//
//  Created by Anton Spivak
//

import Foundation

public extension Wallet4 {
    
    enum Revision {
        
        case r1
        case r2
    }
}

internal extension Wallet4.Revision {
    
    var kind: Contract.Kind {
        switch self {
        case .r1:
            return .walletV4R1
        case .r2:
            return .walletV4R2
        }
    }
}

extension Wallet4.Revision: Codable {}
extension Wallet4.Revision: Hashable {}
