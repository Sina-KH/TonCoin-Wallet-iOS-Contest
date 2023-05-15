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
import Sodium

private let BridgeURL = "https://bridge.tonapi.io/bridge"

public class TonConnectCore {
    
    // MARK: - Initializer
    private init() {
    }
    public static let shared = TonConnectCore()
    
    // get or create a new key pair for wallet ton connect
    private static var walletKeyPair: Box.KeyPair {
        if let keyPairData = KeychainHelper.tonConnectKeyPair()?.data(using: .utf8) {
            if let keyPair = try? JSONDecoder().decode(TonConnectKeyPair.self, from: keyPairData) {
                return Box.KeyPair(publicKey: Array<UInt8>.init(hex: keyPair.publicKey),
                                   secretKey: Array<UInt8>.init(hex: keyPair.privateKey))
            }
        }
        let newKeyPair = BridgeHelpers.newKeyPair()
        let keyPairToStore = TonConnectKeyPair(publicKey: newKeyPair.publicKey.toHex,
                                               privateKey: newKeyPair.secretKey.toHex)
        if let keyPairToStoreData = try? JSONEncoder().encode(keyPairToStore) {
            KeychainHelper.save(keyPair: String(data: keyPairToStoreData, encoding: .utf8))
        }
        return newKeyPair
    }

    // MARK: - Connect to a DApp
    // connect the wallet to an application
    static func connectToApp(url: String,
                             name: String,
                             walletContext: WalletContext,
                             walletInfo: WalletInfo,
                             appPublicKey: String,
                             callback: @escaping (Bool) -> Void) {
        
        // get wallet configuration info
        let _ = (walletContext.storage.localWalletConfiguration()
                 |> take(1)
                 |> deliverOnMainQueue).start(next: { configuration in

            walletInfo.walletStateInit { walletInitialState in
                guard let walletInitialState else {
                    callback(false)
                    return
                }

                let reply = TonConnectItemReplyAddr(address: walletInfo.rawAddress!,
                                                    network: configuration.testNet.customId == "mainnet" ? .mainnet : .testnet,
                                                    publicKey: walletInfo.publicKey.deserializedPublicKey!.toHexString(),
                                                    walletStateInit: walletInitialState)
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
                                                                     features: ["SendTransaction"]) //TonConnectFeature(name: "SendTransaction", maxMessages: Int.max))
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

                let linkKeyPair = TonConnectCore.walletKeyPair
                BridgeEmitter.emit(url: BridgeURL,
                                   walletPrivateKey: linkKeyPair.secretKey,
                                   walletPublicKey: linkKeyPair.publicKey.toHex,
                                   appPublicKey: appPublicKey,
                                   message: messageData) { success in
                    if success {
                        let appPublicKeyBytes = Array<UInt8>.init(hex: appPublicKey)
                        let linkedDApp = LinkedDApp(url: url,
                                                    name: name,
                                                    publicKey: Data(bytes: linkKeyPair.publicKey,
                                                                    count: linkKeyPair.publicKey.count),
                                                    privateKey: Data(bytes: linkKeyPair.secretKey,
                                                                     count: linkKeyPair.secretKey.count),
                                                    appPublicKey: Data(bytes: appPublicKeyBytes,
                                                                       count: appPublicKeyBytes.count),
                                                    lastEventID: 1)
                        TonConnectedDApps.saveDApp(dApp: linkedDApp)
                    }
                    DispatchQueue.main.async {
                        callback(success)
                    }
                }
                
            }

        })
    }
    
    // MARK: - Bridge Listener
    public func startBridgeConnection() {
        let listener = BridgeListener(url: BridgeURL,
                                      walletKeyPair: TonConnectCore.walletKeyPair,
                                      lastEventID: KeychainHelper.tonConnectLastEventID() ?? 0,
                                      delegate: self)
        listener.connect()
    }

}

extension TonConnectCore: BridgeListenerDelegate {
    public func connected() {
        print("Bridge Connection Established!")
    }
    
    public func onMessage(id: String?, event: String?, data: String?) {
        if let lastEventID = Int(id ?? "") {
            KeychainHelper.save(lastEventID: lastEventID)
        }
        print(id)
        print(event)
        print(data)
    }
}
