//
//  Created by Anton Spivak
//

import Foundation

public extension Wallet3 {
    
    struct SubwalletID: RawRepresentable {
        
        public static let `default` = SubwalletID(rawValue: 698983191)
        
        public var rawValue: UInt32
        
        public init(rawValue: UInt32) {
            self.rawValue = rawValue
        }
    }
}
