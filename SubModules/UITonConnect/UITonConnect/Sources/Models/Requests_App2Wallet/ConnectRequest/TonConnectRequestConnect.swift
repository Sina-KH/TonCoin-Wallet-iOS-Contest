//
//  TonConnectConnectRequest.swift
//  UITonConnect
//
//  Created by Sina on 5/9/23.
//

import Foundation

public enum TonConnectItemName: String {
    case ton_addr = "ton_addr"
    case ton_proof = "ton_proof"
}

public struct TonConnectItem: Codable {
    let name: String
    let payload: String?

    public init(name: String, payload: String? = nil) {
        self.name = name
        self.payload = payload
    }
}

public struct TonConnectRequestConnect: Codable {
    let manifestUrl: String
    let items: [TonConnectItem]

    public init(manifestUrl: String, items: [TonConnectItem]) {
        self.manifestUrl = manifestUrl
        self.items = items
    }
}

public struct TonConnectRequestLink {
    let version: Int
    let id: String
    let r: TonConnectRequestConnect
    let ret: String?             // `back`, `none`, or a URL

    public init(version: Int, id: String, r: TonConnectRequestConnect, ret: String? = nil) {
        self.version = version
        self.id = id
        self.r = r
        self.ret = ret
    }
}
