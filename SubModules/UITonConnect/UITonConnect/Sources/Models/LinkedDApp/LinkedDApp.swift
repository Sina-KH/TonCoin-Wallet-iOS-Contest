//
//  LinkedDApp.swift
//  UITonConnect
//
//  Created by Sina on 5/16/23.
//

import Foundation

public struct LinkedDApp: Codable {
    let url: String
    let name: String
    
    let publicKey: Data
    let privateKey: Data
    let appPublicKey: Data

    var lastEventID: Int64
    let bridgeLastEventID: Int64?
}
