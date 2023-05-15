//
//  TonConnectKeyPair.swift
//  UITonConnect
//
//  Created by Sina on 5/16/23.
//

import Foundation

// Struct used to store/restore ton connect keypair from KeyChain
struct TonConnectKeyPair: Codable {
    let publicKey: String
    let privateKey: String
}
