//
//  BridgeMessage.swift
//  Bridge
//
//  Created by Sina on 5/16/23.
//

import Foundation

struct BridgeMessage: Codable {
    let from: String
    let message: Data
}
