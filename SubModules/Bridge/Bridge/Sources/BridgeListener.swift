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
    func onMessage()
}

public class BridgeListener {
    let url: String
    let appPublicKey: Bytes
    let walletKeyPair: Box.KeyPair
    var lastEventID: String?
    let delegate: BridgeListenerDelegate
    public init(url: String,
                appPublicKey: Bytes,
                walletKeyPair: Box.KeyPair,
                lastEventID: String?,
                delegate: BridgeListenerDelegate) {
        self.url = url
        self.appPublicKey = appPublicKey
        self.walletKeyPair = walletKeyPair
        self.lastEventID = lastEventID
        self.delegate = delegate
    }
    
    private var eventSource: EventSource? = nil

    func connect() {
        guard let serverURL = URL(string: url) else {
            return
        }

        eventSource = EventSource(url: serverURL, headers: [:])
            eventSource?.connect()
                
            eventSource?.onComplete({ [self] (statusCode, reconnect, error) in
                eventSource?.connect(lastEventId: self.lastEventID)
            })
                
            eventSource?.onOpen {
                self.delegate.connected()
            }
                
            eventSource?.onMessage({ [self] (id, event, data) in
                guard let id = id else {
                    return
                }
                lastEventID = id

                guard let dataString = data else {
                    return
                }
                
                print("DATAAAAA")
                print(dataString)
//                guard let dict = dataString.convertToDictionary(text: dataString) else {
//                    return
//                }
//                self.delegate.onMessage(message: dict)
            })
    }
    
    func send() {
    }
}
