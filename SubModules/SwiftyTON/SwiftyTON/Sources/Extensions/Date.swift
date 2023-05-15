//
//  Created by Anton Spivak
//

import Foundation

extension Date {
    
    init(utimeInt64 value: Int64) {
        self.init(timeIntervalSince1970: TimeInterval(value))
    }
}
