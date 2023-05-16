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
    func walletInitialCondition(callback: @escaping (Contract.InitialCondition?) -> Void) {
        switch version {
        case -1:        // v3R2 from the original toncoin wallet
            Task {
                guard let initialCondition =
                        try? await Wallet3.initial(subwalletID: Wallet3.SubwalletID(rawValue: 4085333890),
                                                   revision: .r2,
                                                   deserializedPublicKey: publicKey.deserializedPublicKey!)
                else {
                    callback(nil)
                    return
                }
                callback(initialCondition)
            }
        case 31:
            Task {
                guard let initialCondition =
                        try? await Wallet3.initial(revision: .r1, deserializedPublicKey: publicKey.deserializedPublicKey!)
                else {
                    callback(nil)
                    return
                }
                callback(initialCondition)
            }
            break
        case 32:
            Task {
                guard let initialCondition =
                        try? await Wallet3.initial(revision: .r2, deserializedPublicKey: publicKey.deserializedPublicKey!)
                else {
                    callback(nil)
                    return
                }
                callback(initialCondition)
            }
            break
        case 42:
            Task {
                guard let initialCondition =
                        try? await Wallet4.initial(revision: .r2, deserializedPublicKey: publicKey.deserializedPublicKey!)
                else {
                    callback(nil)
                    return
                }
                callback(initialCondition)
            }
            break
        default:
            return
        }
    }
    func walletStateInit(callback: @escaping (String?) -> Void) {
        walletInitialCondition { initialCondition in
            callback(initialCondition?.data.base64EncodedString())
        }
    }
}
