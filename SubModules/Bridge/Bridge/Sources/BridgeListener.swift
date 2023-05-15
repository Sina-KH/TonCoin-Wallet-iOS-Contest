//
//  BridgeListener.swift
//  Bridge
//
//  Created by Sina on 5/9/23.
//

import Foundation
import Sodium

public protocol BridgeListenerDelegate {
    func connected()
    func onMessage(id: String?, event: String?, data: String?)
}

public class BridgeListener {
    let url: String
    let walletKeyPair: Box.KeyPair
    var lastEventID: Int
    let delegate: BridgeListenerDelegate
    public init(url: String,
                walletKeyPair: Box.KeyPair,
                lastEventID: Int,
                delegate: BridgeListenerDelegate) {
        self.url = url
        self.walletKeyPair = walletKeyPair
        self.lastEventID = lastEventID
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
                lastEventID = Int(id) ?? 0

                guard let dataString = data else {
                    return
                }
                
                delegate.onMessage(id: id, event: event, data: data)
            })
    }
    
    public func send() {
    }
}
