//
//  AddressHelpers.swift
//  WalletContext
//
//  Created by Sina on 5/15/23.
//

import Foundation
import WalletCore
import SwiftSignalKit

public struct ContextAddressHelpers {
    
    public static func toBase64Address(unknownAddress: String,
                                walletContext: WalletContext,
                                callback: @escaping (String?) -> Void) {
        let isValid = isValidAddress(unknownAddress, exactLength: true)
        if isValid {
            callback(unknownAddress)
            return
        }
        let isDNS = isTONDNSDomain(string: unknownAddress)
        if isDNS {
            _ = (resolveDNSAddress(tonInstance: walletContext.tonInstance, address: unknownAddress)
            |> deliverOnMainQueue).start(next: { resolvedAddress in
                if isValidAddress(resolvedAddress, exactLength: true) {
                    callback(resolvedAddress)
                } else {
                    callback(nil)
                }
            }, error: { error in
                callback(nil)
            })
            return
        } else {
            callback(AddressHelpers.rawToAddress(rawAddress: unknownAddress))
        }
    }
    
    private static func isTONDNSDomain(
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
