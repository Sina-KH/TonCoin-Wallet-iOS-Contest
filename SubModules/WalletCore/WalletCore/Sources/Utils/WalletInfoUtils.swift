//
//  WalletInfoUtils.swift
//  WalletCore
//
//  Created by Sina on 5/15/23.
//

import Foundation
import SwiftyTON

public extension WalletInfo {
    var rawAddress: String? {
        return AddressHelpers.addressToRaw(string: address)
    }
    func walletStateInit(callback: @escaping (String?) -> Void) {
        switch version {
        case 31:
            Task {
                guard let initialCondition =
                        try? await Wallet3.initial(revision: .r1, deserializedPublicKey: publicKey.rawValue.data(using: .utf8)!)
                else {
                    callback(nil)
                    return
                }
                callback(initialCondition.data.base64EncodedString())
            }
            break
        case 32:
            Task {
                guard let initialCondition =
                        try? await Wallet3.initial(revision: .r2, deserializedPublicKey: publicKey.rawValue.data(using: .utf8)!)
                else {
                    callback(nil)
                    return
                }
                callback(initialCondition.data.base64EncodedString())
            }
            break
        case 42:
            Task {
                guard let initialCondition =
                        try? await Wallet4.initial(revision: .r2, deserializedPublicKey: publicKey.rawValue.data(using: .utf8)!)
                else {
                    callback(nil)
                    return
                }
                callback(initialCondition.data.base64EncodedString())
            }
            break
        default:
            return
        }
    }
}
