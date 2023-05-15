//
//  Created by Anton Spivak
//

import Foundation

public protocol CustomConcreteAddressConvertible {
    
    var displayName: String { get }
    var concreteAddress: ConcreteAddress { get }
}
