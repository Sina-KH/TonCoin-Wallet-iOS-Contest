//
//  RecentAddress.swift
//  UIWalletSend
//
//  Created by Sina on 5/18/23.
//

import Foundation

public struct RecentAddress: Codable {
    let address: String
    let addressAlias: String?
    let timstamp: Double

    public init(address: String, addressAlias: String?, timstamp: Double) {
        self.address = address
        self.addressAlias = addressAlias
        self.timstamp = timstamp
    }
}
