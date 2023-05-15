//
//  Created by Anton Spivak
//

import Foundation

public extension ConcreteAddress {
    
    struct Flags: OptionSet {
        
        public let rawValue: Int
        
        public static let bounceable = Flags(rawValue: 1 << 0)
        public static let testable = Flags(rawValue: 1 << 1)
        
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }
}

extension ConcreteAddress.Flags: Codable {}
extension ConcreteAddress.Flags: Hashable {}
