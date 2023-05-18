//
//  AddressHelpers.swift
//  WalletCore
//
//  Created by Sina on 5/14/23.
//

import Foundation
import SwiftyTON
import CryptoSwift

public class AddressHelpers {
    
    private init() {}
    
    public static func rawToAddress(rawAddress: String) -> String? {
        let range = NSRange(location: 0, length: rawAddress.count)
        let regex = NSRegularExpression.tonRawAddress
        let matches = regex.matches(in: rawAddress, options: [], range: range)
        
        guard matches.count == 1
        else {
            return nil
        }
        
        let match = matches[0]
        
        guard let workchain = Int32((rawAddress as NSString).substring(with: match.range(at: 1)))
        else {
            return nil
        }
        
        let address = (rawAddress as NSString).substring(with: match.range(at: 2))
        guard address.count == 64
        else {
            return nil
        }
        
        return ConcreteAddress(address: Address(
                workchain: workchain,
                hash: Array<UInt8>(hex: address)
            )
        ).description
    }
    
    public static func addressToRaw(string: String) -> String? {
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
        
        var workchain = Int32(-1)

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
        
        return Address(
            workchain: workchain,
            hash: Array(data[2..<34])
        ).rawValue
    }

    public static func isTONDNSDomain(
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
}
