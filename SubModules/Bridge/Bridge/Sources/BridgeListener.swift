//
//  BridgeListener.swift
//  Bridge
//
//  Created by Sina on 5/9/23.
//

import Foundation
import Sodium
import WalletContext

public protocol BridgeListenerDelegate {
    func connected()
    func onMessage(walletVersion: Int, id: String?, event: String?, from: Bytes, data: Data)
}

public class BridgeListener {
    let url: String
    public let dAppURL: String
    let walletKeyPair: Box.KeyPair
    var lastEventID: Int64
    public let walletVersion: Int
    let delegate: BridgeListenerDelegate
    public init(url: String,
                dAppURL: String,
                walletKeyPair: Box.KeyPair,
                lastEventID: Int64,
                walletVersion: Int,
                delegate: BridgeListenerDelegate) {
        self.url = url
        self.dAppURL = dAppURL
        self.walletKeyPair = walletKeyPair
        self.lastEventID = lastEventID
        self.walletVersion = walletVersion
        self.delegate = delegate
    }
    
    private var eventSource: EventSource? = nil

    public func connect() {
        guard let serverURL = URL(string: url) else {
            return
        }

        eventSource = EventSource(url: URL(string: "\(serverURL)/events?client_id=\(walletKeyPair.publicKey.toHex)")!, headers: [:])
            eventSource?.connect()
                
            eventSource?.onComplete({ [self] (statusCode, reconnect, error) in
                eventSource?.connect(lastEventId: "\(self.lastEventID)")
            })
                
            eventSource?.onOpen {
                self.delegate.connected()
            }
                
            eventSource?.onMessage({ [self] (id, event, data) in
                guard let id = id else {
                    return
                }
                if let lastEventID = Int(id) {
                    if self.lastEventID >= lastEventID {
                        return
                    }
                }

                guard let data = data?.data(using: .utf8) else {
                    return
                }
                guard let bridgeMessage = try? JSONDecoder().decode(BridgeMessage.self, from: data) else {
                    return
                }
                guard let internalMessage = SessionProtocol.decrypt(message: [UInt8](bridgeMessage.message),
                                                              senderPublicKey: Array<UInt8>.init(hex: bridgeMessage.from),
                                                                    recipientSecretKey: walletKeyPair.secretKey) else {
                    return
                }
                DispatchQueue.main.async {
                    self.delegate.onMessage(walletVersion: self.walletVersion,
                                            id: id,
                                            event: event,
                                            from: Array<UInt8>(hex: bridgeMessage.from),
                                            data: Data(bytes: internalMessage, count: internalMessage.count))
                }
            })
    }
    
    public func disconnect() {
        eventSource?.disconnect()
    }
    
    public func destroy() {
        eventSource = nil
    }
    
}
