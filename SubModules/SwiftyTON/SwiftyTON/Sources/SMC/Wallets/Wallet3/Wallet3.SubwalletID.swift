//
//  Created by Anton Spivak
//

import Foundation

public extension Wallet3 {
    
    struct SubwalletID: RawRepresentable {
        
        public static let `default` = SubwalletID(rawValue: 698983191)
        
        public var rawValue: Int32
        
        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }
    }
}
