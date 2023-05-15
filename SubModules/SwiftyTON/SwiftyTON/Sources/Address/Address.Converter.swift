//
//  Created by Anton Spivak
//

import Foundation
import CryptoSwift

internal extension Address {
    
    struct Converter {}
}

internal extension Address.Converter {
    
//    /// - returns: dns parsed address if available
//    static func resolve(
//        domain: String
//    ) async -> ConcreteAddress? {
//        guard isTONDNSDomain(string: domain)
//        else {
//            return nil
//        }
//        
//        let dns = try? await wrapper.resolvedDNSWithRootDNSAccountAddress(
//            nil,
//            name: domain,
//            category: .wallet,
//            ttl: 5 // allow recursively search up to 5 times
//        )
//        
//        guard let entry = dns?.entries.compactMap({ $0 as? GTDNSEntrySMCAddress }).first
//        else {
//            return nil
//        }
//        
//        return ConcreteAddress(string: entry.address)
//    }
//    
    static func isTONDNSDomain(
        string: String
    ) -> Bool {
        let range = NSRange(location: 0, length: string.count)
        let regex = NSRegularExpression.tonDNSAddress
        let matches = regex.matches(in: string, options: [], range: range)
        
        guard matches.count == 1,
              (string as NSString).substring(with: matches[0].range(at: 0)) == string
        else {
            return false
        }
        
        return true
    }
    
    /// - returns: always .base64url ConcreteAddress if aailable
    static func base64(
        string: String
    ) -> ConcreteAddress? {
        let unescaped = string.base64URLUnescaped()
        guard let data = Data(base64Encoded: unescaped)
        else {
            return nil
        }
        
        // 0..<1: one tag byte (0x11 for "bounceable" addresses, 0x51 for "non-bounceable";
        // add +0x80 if the address should not be accepted by software running in the production network)
        // ---
        // 1..<2: one byte containing a signed 8-bit integer with the workchain_id (0x00 for the basic workchain, 0xff for the masterchain)
        // ---
        // 2..<34: 32 bytes containing 256 bits of the smart-contract address inside the workchain (big-endian)
        // ---
        // 34..<36: 2 bytes containing CRC16-CCITT of the previous 34 bytes
        
        // invalidBase64String
        guard data.count == 36
        else {
            return nil
        }
        
        let address = Data(data[0..<34])
        let crc = Data(data[34..<36])
        let hashsum = address.crc16ccitt()
        
        // invalidCRC15Hashsum
        guard hashsum[0] == crc[0], hashsum[1] == crc[1]
        else {
            return nil
        }
        
        var tag = address[0]
        var flags: ConcreteAddress.Flags = []
        var workchain = Int32(-1)
        
        if tag & Tags.test != 0 {
            flags.insert(.testable)
            tag = tag ^ Tags.test
        }
        
        switch tag {
        case Tags.bounceable:
            flags.insert(.bounceable)
        case Tags.nonBounceable:
            break
        default:
            // unknownAddressTags
            return nil
        }
        
        if address[1] == 0xff {
            workchain = -1
        } else if address[1] == 0x00 {
            workchain = 0
        } else {
            workchain = Int32(Int8(address[1] - 128))
        }
        
        // unsupportedWorkchain
        guard workchain == -1 || workchain == 0
        else {
            return nil
        }
        
        return ConcreteAddress(
            address: Address(
                workchain: workchain,
                hash: Array(data[2..<34])
            ),
            representation: .base64url(flags: flags)
        )
    }
    
    static func raw(
        string: String
    ) -> Address? {
        let range = NSRange(location: 0, length: string.count)
        let regex = NSRegularExpression.tonRawAddress
        let matches = regex.matches(in: string, options: [], range: range)
        
        guard matches.count == 1
        else {
            return nil
        }
        
        let match = matches[0]
        
        guard let workchain = Int32((string as NSString).substring(with: match.range(at: 1)))
        else {
            return nil
        }
        
        let address = (string as NSString).substring(with: match.range(at: 2))
        guard address.count == 64
        else {
            return nil
        }
        
        return Address(
            workchain: workchain,
            hash: Array<UInt8>(hex: address)
        )
    }
    
    static func string(
        concreteAddress: ConcreteAddress
    ) -> String {
        var data = Data()
        var tag = UInt8()
        var workchain = UInt8()
        
        if concreteAddress.representation.flags.contains(.bounceable) {
            tag = Tags.bounceable
        } else {
            tag = Tags.nonBounceable
        }
        if concreteAddress.representation.flags.contains(.testable) {
            tag = tag | Tags.test
        }
        
        switch concreteAddress.address.workchain {
        case 0:
            workchain = 0x00
        case -1:
            workchain = 0xff
        default:
            workchain = UInt8(workchain + 127)
        }
        
        data.append(tag)
        data.append(workchain)
        data.append(contentsOf: concreteAddress.address.hash)
        data.append(data.crc16ccitt())
        
        switch concreteAddress.representation {
        case .base64url:
            return data.base64EncodedString().base64URLEscaped()
        case .base64:
            return data.base64EncodedString()
        }
    }
    
    static func string(
        address: Address
    ) -> String {
        "\(address.workchain):\(address.hash.toHexString())"
    }
}

private extension Address.Converter {
    
    struct Tags {
        
        static let bounceable: UInt8 = 0x11
        static let nonBounceable: UInt8 = 0x51
        static let test: UInt8 = 0x80
    }
}
