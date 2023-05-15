//
//  Created by Anton Spivak
//

import Foundation
import CryptoSwift

public struct DNSAddress {
    
    public var domain: String
    public var redirectAddress: ConcreteAddress
    
    public init?(
        domain: String,
        redirectAddress: ConcreteAddress
    ) {
        guard DNSAddress.isTONDomain(string: domain)
        else {
            return nil
        }
        
        self.domain = domain
        self.redirectAddress = redirectAddress
    }
    
//    public init?(
//        string: String
//    ) async {
//        if let redirectAddress = await Address.Converter.resolve(domain: string) {
//            self.init(
//                domain: string,
//                redirectAddress: redirectAddress
//            )
//        } else {
//            return nil
//        }
//    }
    
    public static func isTONDomain(
        string: String
    ) -> Bool {
        Address.Converter.isTONDNSDomain(string: string)
    }
}

extension DNSAddress: CustomStringConvertible {
    
    public var description: String {
        domain
    }
}

extension DNSAddress: CustomConcreteAddressConvertible {
    
    public var displayName: String {
        domain
    }
    
    public var concreteAddress: ConcreteAddress {
        redirectAddress
    }
}

extension DNSAddress: Codable {}
extension DNSAddress: Hashable {}
