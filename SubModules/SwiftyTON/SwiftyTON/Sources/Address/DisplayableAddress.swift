//
//  Created by Anton Spivak
//

import Foundation

public struct DisplayableAddress: RawRepresentable {
    
    public let rawValue: CustomConcreteAddressConvertible
    
    public var displayName: String { rawValue.displayName }
    public var concreteAddress: ConcreteAddress { rawValue.concreteAddress }
    
    public init(
        rawValue: CustomConcreteAddressConvertible
    ) {
        self.rawValue = rawValue
    }
    
//    public init?(
//        string: String
//    ) async {
//        if let address = ConcreteAddress(string: string) {
//            self.init(rawValue: address)
//        } else if let address = await DNSAddress(string: string) {
//            self.init(rawValue: address)
//        } else {
//            return nil
//        }
//    }
}
