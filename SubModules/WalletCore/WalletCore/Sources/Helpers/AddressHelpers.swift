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
        ).rawValue
    }
}
