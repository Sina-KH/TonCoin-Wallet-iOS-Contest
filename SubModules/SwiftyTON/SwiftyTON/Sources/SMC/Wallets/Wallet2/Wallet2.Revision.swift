//
//  Created by Anton Spivak
//

import Foundation

public extension Wallet2 {
    
    enum Revision {
        
        case r1
        case r2
    }
}

internal extension Wallet2.Revision {
    
    var kind: Contract.Kind {
        switch self {
        case .r1:
            return .walletV2R1
        case .r2:
            return .walletV2R2
        }
    }
}

extension Wallet2.Revision: Codable {}
extension Wallet2.Revision: Hashable {}
