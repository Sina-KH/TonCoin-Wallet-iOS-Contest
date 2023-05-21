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

// TODO:: Should be replaced with wallet's own bridge
private let BridgeURL = "https://bridge.tonapi.io/bridge"

public protocol TonConnectCoreDelegate: AnyObject {
    func tonConnectSendTransaction(dApp: LinkedDApp,
                                   requestID: Int64,
                                   request: TonConnectSendTransaction,
                                   fromAddress: String?,
                                   network: String?)
}

// Wrapper around Bridge and SessionProtocol, to let wallet communicate dApps.
public class TonConnectCore {
    
    // MARK: - Initializer
    private init() {
    }
    // listeners are on shared instance
    public static let shared = TonConnectCore()
    public weak var delegate: TonConnectCoreDelegate? = nil

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
                    DispatchQueue.main.async {
                        callback(false)
                    }
                    return
                }

                let linkKeyPair = BridgeHelpers.newKeyPair()
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
                    DispatchQueue.main.async {
                        callback(false)
                    }
                    return
                }
                let messageData = try? JSONSerialization.data(withJSONObject: messageJSONObject)
                guard let messageData else {
                    DispatchQueue.main.async {
                        callback(false)
                    }
                    return
                }

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
                                                    lastEventID: 1,
                                                    bridgeLastEventID: nil)
                        TonConnectedDApps.saveDApp(dApp: linkedDApp, walletVersion: walletInfo.version)
                        shared.connectBridge(to: linkedDApp, walletVersion: walletInfo.version)
                    }
                    DispatchQueue.main.async {
                        callback(success)
                    }
                }
                
            }

        })
    }
    public static func connectRequestCanceled(url: String,
                                              name: String,
                                              walletContext: WalletContext,
                                              walletInfo: WalletInfo,
                                              appPublicKey: String,
                                              callback: @escaping (Bool) -> Void) {
        let message = TonConnectEventError(event: "connect_error",
                                           id: 1,
                                           payload: TonConnectEventErrorPayload(code: .userDeclinedTheConnection, message: ""))
        let messageJSONObject = try? JSONSerialization.jsonObject(with: JSONEncoder().encode(message))
        guard let messageJSONObject else {
            DispatchQueue.main.async {
                callback(false)
            }
            return
        }
        let messageData = try? JSONSerialization.data(withJSONObject: messageJSONObject)
        guard let messageData else {
            DispatchQueue.main.async {
                callback(false)
            }
            return
        }

        let linkKeyPair = BridgeHelpers.newKeyPair()
        BridgeEmitter.emit(url: BridgeURL,
                           walletPrivateKey: linkKeyPair.secretKey,
                           walletPublicKey: linkKeyPair.publicKey.toHex,
                           appPublicKey: appPublicKey,
                           message: messageData) { success in
            DispatchQueue.main.async {
                callback(success)
            }
        }
    }
    
    // MARK: - Send Response to App
    private static func send(to appID: String, walletVersion: Int, jsonObject: Any, callback: @escaping (Bool) -> Void) {
        let messageData = try? JSONSerialization.data(withJSONObject: jsonObject)
        guard let messageData else {
            DispatchQueue.main.async {
                callback(false)
            }
            return
        }
        guard let dApp = TonConnectedDApps.findDApp(walletVersion: walletVersion, publicKey: Data(hex: appID)) else {
            return
        }
        BridgeEmitter.emit(url: BridgeURL,
                           walletPrivateKey: [UInt8](dApp.privateKey),
                           walletPublicKey: dApp.publicKey.toHexString(),
                           appPublicKey: appID,
                           message: messageData) { success in
            DispatchQueue.main.async {
                callback(success)
            }
        }
    }
    public static func sendResponse(to appID: String,
                                    walletVersion: Int,
                                    response: TonConnectResponseSuccess,
                                    callback: @escaping (Bool) -> Void) {
        let messageJSONObject = try? JSONSerialization.jsonObject(with: JSONEncoder().encode(response))
        guard let messageJSONObject else {
            DispatchQueue.main.async {
                callback(false)
            }
            return
        }
        send(to: appID, walletVersion: walletVersion, jsonObject: messageJSONObject, callback: callback)
    }
    public static func sendError(to appID: String, walletVersion: Int, error: TonConnectResponseError, callback: @escaping (Bool) -> Void) {
        let messageJSONObject = try? JSONSerialization.jsonObject(with: JSONEncoder().encode(error))
        guard let messageJSONObject else {
            DispatchQueue.main.async {
                callback(false)
            }
            return
        }
        send(to: appID, walletVersion: walletVersion, jsonObject: messageJSONObject, callback: callback)
    }
    
    // MARK: - Bridge Listener
    private var bridgeListeners = [BridgeListener]()
    public func startBridgeConnection(walletInfo: WalletInfo) {
        stopBridgeConnection()
        let dApps = TonConnectedDApps.linkedDApps(walletVersion: walletInfo.version)
        for dApp in dApps {
            let bridgeListener = BridgeListener(url: BridgeURL,
                                                dAppURL: dApp.url,
                                                walletKeyPair: Box.KeyPair(publicKey: [UInt8](dApp.publicKey), secretKey: [UInt8](dApp.privateKey)),
                                                lastEventID: dApp.lastEventID,
                                                walletVersion: walletInfo.version,
                                                delegate: self)
            bridgeListener.connect()
            bridgeListeners.append(bridgeListener)
        }
    }
    private func connectBridge(to dApp: LinkedDApp, walletVersion: Int) {
        for (i, listener) in bridgeListeners.enumerated() {
            if listener.dAppURL == dApp.url {
                listener.disconnect()
                listener.destroy()
                bridgeListeners.remove(at: i)
                break
            }
        }
        let bridgeListener = BridgeListener(url: BridgeURL,
                                            dAppURL: dApp.url,
                                            walletKeyPair: Box.KeyPair(publicKey: [UInt8](dApp.publicKey), secretKey: [UInt8](dApp.privateKey)),
                                            lastEventID: dApp.lastEventID,
                                            walletVersion: walletVersion,
                                            delegate: self)
        bridgeListener.connect()
        bridgeListeners.append(bridgeListener)
    }
    public func stopBridgeConnection() {
        for listener in bridgeListeners {
            listener.disconnect()
            listener.destroy()
        }
        bridgeListeners = []
    }

}

extension TonConnectCore: BridgeListenerDelegate {
    public func connected() {
        print("Bridge Connection Established!")
    }
    
    public func onMessage(walletVersion: Int, id: String?, event: String?, from: Bytes, data: Data) {
        guard let request = try? JSONDecoder().decode(TonConnectAppRequest.self, from: data) else {
            return
        }
        switch request.method {
        case "sendTransaction":
            for param in request.params {
                guard let sendTransactionRequests = try? JSONDecoder().decode(TonConnectSendTransactionMessages.self,
                                                                              from: param.data(using: .utf8)!) else {
                    return
                }
                guard var dApp = TonConnectedDApps.findDApp(walletVersion: walletVersion,
                                                            publicKey: Data(bytes: from, count: from.count)) else {
                    return
                }
                if let lastEventID = Int64(id ?? "") {
                    dApp.lastEventID = lastEventID
                    TonConnectedDApps.saveDApp(dApp: dApp, walletVersion: walletVersion)
                }
                if sendTransactionRequests.messages.count > 1 {
                    // TODO:: Check desired behaviour for more than one message. (UI design/flow, seems to be required)
                    return
                }
                for sendTransactionRequest in sendTransactionRequests.messages {
                    delegate?.tonConnectSendTransaction(
                        dApp: dApp,
                        requestID: request.id,
                        request: sendTransactionRequest,
                        fromAddress: sendTransactionRequests.from,
                        network: sendTransactionRequests.network
                    )
                }
            }
            break
        default:
            // unknown requests
            TonConnectCore.sendError(to: Data(bytes: from, count: from.count).toHexString(),
                                     walletVersion: walletVersion,
                                     error: TonConnectResponseError(id: "\(request.id)",
                                                                    error: TonConnectEventErrorPayload(code: .methodNotSupported,
                                                                                                       message: ""))) { _ in
            }
            break
        }
    }
}
