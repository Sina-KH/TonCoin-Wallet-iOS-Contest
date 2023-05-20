//
//  TONQueryHelpers.swift
//  WalletCore
//
//  Created by Sina on 5/19/23.
//

import Foundation
import SwiftyTON
import TON3
import TonBinding

class TONQueryHelpers {
    
    private static let fakePrivateKey = Data(bytes: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
                                             count: 32)
    
    // return subwallet id for wallet, based on version
    private static func subwalletID(walletInfo: WalletInfo) -> UInt32? {
        switch walletInfo.version {
        case -1:
            return 4085333890
        case 31, 32, 42:
            return 698983191
        default:
            return nil
        }
    }
    
    private static func subsequentExternalMessage(walletInfo: WalletInfo, seqno: Int64, sendMode: Int) async throws -> [UInt8] {
        let builder = try await TON3.Builder()
        await builder.store(TONQueryHelpers.subwalletID(walletInfo: walletInfo)!)
        await builder.store(UInt32(Date().timeIntervalSince1970 + 60))
        await builder.store(UInt32(seqno))
        if walletInfo.version == 42 {
            await builder.store(UInt8(0)) // op
        }
        await builder.store(UInt8(sendMode))

        let boc = try await builder.boc()
        return [UInt8](hex: boc)
    }

    // query data to prepare a send ton query
    static func sendTONQueryData(
        walletInfo: WalletInfo,
        decryptedKey: Data? = nil,
        toAddress: String,
        bouncable: Bool,
        amount: Int64,
        message: Data,
        seqno: Int64,
        sendMode: Int,
        callback: @escaping (Address, Contract.InitialCondition?, Data) -> Void
    ) {
        walletInfo.walletInitialCondition { initialCondition in
            guard let initialCondition else {
                return
            }

        let (sourceAddress, _) = AddressHelpers.addressToAddressObj(string: walletInfo.address)!
        let (tonToAddress, _) = AddressHelpers.addressToAddressObj(string: toAddress)!

        Task {
            let external = try await TONQueryHelpers.subsequentExternalMessage(walletInfo: walletInfo, seqno: seqno, sendMode: sendMode)
            let subsequentExternalMessageBody = try await TON3.transfer(
                external: external,
                workchain: tonToAddress.workchain,
                address: tonToAddress.hash,
                amount: amount,
                bounceable: bouncable,
                payload: message.bytes,
                state: nil
            )
            
            let boc = BOC(bytes: subsequentExternalMessageBody)
            let bocHash = try await TON3.createBOCHash(data: boc.data)
            let signiture = GTTONKey.createSignature(with: bocHash, privateKey: decryptedKey ?? TONQueryHelpers.fakePrivateKey)!
            let signedBOC = try await boc.signed(with: signiture)
            callback(sourceAddress,
                     seqno == 0 ? initialCondition : nil,
                     signedBOC.data)
        }

        }

    }
}
