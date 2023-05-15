//
//  Created by Anton Spivak
//

import Foundation

public extension Contract {
    
    struct InitialCondition {
        
        public let kind: Kind
        public let data: Data
        
        public init(
            kind: Kind,
            data: Data
        ) {
            self.kind = kind
            self.data = data
        }
    }
}

extension Contract.InitialCondition: Codable {}
extension Contract.InitialCondition: Hashable {}
