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
        let isValid = isValidAddress(unknownAddress.base64URLEscaped(), exactLength: true)
        if isValid {
            callback(unknownAddress)
            return
        }
        let isDNS = AddressHelpers.isTONDNSDomain(string: unknownAddress)
        if isDNS {
            _ = (resolveDNSAddress(tonInstance: walletContext.tonInstance, address: unknownAddress.lowercased())
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
}
