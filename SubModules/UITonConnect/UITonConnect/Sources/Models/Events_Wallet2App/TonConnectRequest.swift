//
//  TonConnectRequest.swift
//  UITonConnect
//
//  Created by Sina on 5/9/23.
//

import Foundation

struct TonConnectAppRequest: Codable {
    let method: String
    let params: [String]
    let id: Int64
}
