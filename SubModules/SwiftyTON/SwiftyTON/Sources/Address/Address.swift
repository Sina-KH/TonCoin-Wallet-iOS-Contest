//
//  Created by Anton Spivak
//

import Foundation
import CryptoSwift

public struct Address: RawRepresentable {
    
    public var rawValue: String {
        Address.Converter.string(address: self)
    }
    
    public let workchain: Int32
    public let hash: [UInt8]
    
    public init?(
        rawValue: String
    ) {
        guard let address = Converter.raw(string: rawValue)
        else {
            return nil
        }
        
        self = address
    }
    
    public init(
        workchain: Int32,
        hash: [UInt8]
    ) {
        self.workchain = workchain
        self.hash = hash
    }
    
//    public init?(
//        workchain: Int32 = 0,
//        initial: Contract.InitialCondition
//    ) async {
//        await self.init(
//            workchain: workchain,
//            initial: (code: initial.kind.rawValue.data, data: initial.data)
//        )
//    }
    
//    public init?(
//        workchain: Int32 = 0,
//        initial: (code: Data, data: Data)
//    ) async {
//        let base64Address = try? await wrapper.accountAddress(
//            code: initial.code,
//            data: initial.data,
//            workchain: workchain
//        )
//
//        guard let base64Address = base64Address,
//              let concreteAddress = Converter.base64(string: base64Address)
//        else {
//            return nil
//        }
//
//        self.init(
//            workchain: concreteAddress.address.workchain,
//            hash: concreteAddress.address.hash
//        )
//    }
}

extension Address: CustomStringConvertible {
    
    public var description: String {
        rawValue
    }
}

extension Address: Codable {}
extension Address: Hashable {}
