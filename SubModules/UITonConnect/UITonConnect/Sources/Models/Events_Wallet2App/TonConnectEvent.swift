//
//  TonConnectEvent.swift
//  UITonConnect
//
//  Created by Sina on 5/9/23.
//

import Foundation

protocol TonConnectEvent {
    associatedtype Payload

    var event: String { get }
    var id: Int { get }
    var payload: Payload { get }
}
