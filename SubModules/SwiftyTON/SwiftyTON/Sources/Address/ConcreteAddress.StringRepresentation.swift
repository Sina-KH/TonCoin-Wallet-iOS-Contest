//
//  Created by Anton Spivak
//

import Foundation

public extension ConcreteAddress {
    
    indirect enum StringRepresentation {

        /// e.g. `kf/8uRo6OBbQ97jCx2EIuKm8Wmt6Vb15+KsQHFLbKSMiYIny`
        case base64(flags: ConcreteAddress.Flags)

        /// e.g. `kf_8uRo6OBbQ97jCx2EIuKm8Wmt6Vb15-KsQHFLbKSMiYIny`
        case base64url(flags: ConcreteAddress.Flags)
    }
}

extension ConcreteAddress.StringRepresentation: Codable {}
extension ConcreteAddress.StringRepresentation: Hashable {}

public extension ConcreteAddress.StringRepresentation {
    
    var flags: ConcreteAddress.Flags {
        switch self {
        case let .base64(flags):
            return flags
        case let .base64url(flags):
            return flags
        }
    }
}
