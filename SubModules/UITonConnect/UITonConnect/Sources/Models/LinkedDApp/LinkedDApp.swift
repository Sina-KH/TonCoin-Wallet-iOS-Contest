//
//  LinkedDApp.swift
//  UITonConnect
//
//  Created by Sina on 5/16/23.
//

import Foundation

struct LinkedDApp: Codable {
    let url: String
    let name: String
    
    let publicKey: Data
    let privateKey: Data
    let appPublicKey: Data

    let lastEventID: Int
}
