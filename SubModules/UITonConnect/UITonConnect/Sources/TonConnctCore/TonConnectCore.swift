//
//  TonConnectCore.swift
//  UITonConnect
//
//  Created by Sina on 5/11/23.
//

import Foundation
import UIKit
import WalletCore
import WalletContext
import Bridge
import SwiftSignalKit

class TonConnectCore {
    static func startBridgeConnections() {
        
    }
    
    // connect the wallet to an application
    static func connectToApp(url: String,
                             walletContext: WalletContext,
                             walletInfo: WalletInfo,
                             appPublicKey: String,
                             callback: @escaping (Bool) -> Void) {
        
        // get wallet configuration info
        let _ = (walletContext.storage.localWalletConfiguration()
                 |> take(1)
                 |> deliverOnMainQueue).start(next: { configuration in
        
            // get wallet private key
            let _ = (walletContext.keychain.decrypt(walletInfo.encryptedSecret)
                     |> deliverOnMainQueue).start(next: { decryptedSecret in
                    
                    
                    let reply = TonConnectItemReplyAddr(address: walletInfo.address, // TODO:: TON address raw (`0:<hex>`)
                                                        network: configuration.testNet.customId == "mainnet" ? .mainnet : .testnet,
                                                        publicKey: walletInfo.publicKey.rawValue, // TODO:: HEX WITHOUT 0x
                                                        walletStateInit: walletInfo.publicKey.rawValue)
                    let platform: TonConnectEventSuccessPayloadDeviceInfo.Platform
                    switch UIDevice.current.userInterfaceIdiom {
                    case .pad:
                        platform = .iPad
                        break
                    case .mac:
                        platform = .mac
                        break
                    case .phone:
                        platform = .iPhone
                        break
                    default:
                        platform = .mac // defaults to `mac`
                        break
                    }
                    let appName = Bundle.main.infoDictionary?[kCFBundleNameKey as String] as? String
                    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
                    let device = TonConnectEventSuccessPayloadDeviceInfo(platform: platform,
                                                                         appName: appName ?? "",
                                                                         appVersion: appVersion ?? "",
                                                                         maxProtocolVersion: 2,
                                                                         features: TonConnectFeature(name: "SendTransaction", maxMessages: Int.max))
                    let message = TonConnectEventSuccess(id: 1,
                                                         payload: TonConnectEventSuccessPayload(items: [reply],
                                                                                                device: device))
                    let messageJSONObject = try? JSONSerialization.jsonObject(with: JSONEncoder().encode(message))
                    guard let messageJSONObject else {
                        callback(false)
                        return
                    }
                    let messageData = try? JSONSerialization.data(withJSONObject: messageJSONObject)
                    guard let messageData else {
                        callback(false)
                        return
                    }

                    BridgeEmitter.emit(url: url,
                                       walletPrivateKey: decryptedSecret,
                                       walletPublicKey: walletInfo.publicKey.rawValue.data(using: .ascii)!.hexEncodedString(),
                                       appPublicKey: appPublicKey,
                                       message: messageData) { success in
                        if success {
                            // TODO:: Add to local wallet applications
                        }
                        callback(success)
                    }
                    
                }, error: { _ in
                    callback(false)
                })
        })
    }
}
