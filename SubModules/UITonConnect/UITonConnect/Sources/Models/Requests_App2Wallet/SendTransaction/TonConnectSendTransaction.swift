//
//  TonConnectSendTransaction.swift
//  UITonConnect
//
//  Created by Sina on 5/16/23.
//

import Foundation

public struct TonConnectSendTransaction: Codable {
    public let address: String
    public let amount: String
    public let stateInit: String
}
