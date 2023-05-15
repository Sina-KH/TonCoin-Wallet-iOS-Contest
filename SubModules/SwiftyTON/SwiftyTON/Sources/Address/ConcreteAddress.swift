//
//  Created by Anton Spivak
//

import Foundation
import CryptoSwift

public struct ConcreteAddress {
    
    public var address: Address
    public var representation: StringRepresentation
    
    public init(
        address: Address,
        representation: StringRepresentation = .base64url(flags: [.bounceable])
    ) {
        self.address = address
        self.representation = representation
    }
    
    public init?(
        string: String
    ) {
        if let address = Address(rawValue: string) {
            self.init(address: address)
        } else if let concreteAddress = Address.Converter.base64(string: string) {
            self = concreteAddress
        } else {
            return nil
        }
    }
}

extension ConcreteAddress: CustomStringConvertible {
    
    public var description: String {
        Address.Converter.string(concreteAddress: self)
    }
}

extension ConcreteAddress: CustomConcreteAddressConvertible {
    
    public var displayName: String {
        description
    }
    
    public var concreteAddress: ConcreteAddress {
        self
    }
}

extension ConcreteAddress: Codable {}
extension ConcreteAddress: Hashable {}
