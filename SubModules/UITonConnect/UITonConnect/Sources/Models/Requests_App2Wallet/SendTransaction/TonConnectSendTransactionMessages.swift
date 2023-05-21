//
//  TonConnectRequests.swift
//  UITonConnect
//
//  Created by Sina on 5/16/23.
//

import Foundation

struct TonConnectSendTransactionMessages: Codable {
    let from: String?
    let network: String?
    let messages: [TonConnectSendTransaction]
    let valid_until: Int
}
