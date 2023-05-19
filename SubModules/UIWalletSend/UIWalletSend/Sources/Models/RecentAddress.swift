//
//  RecentAddress.swift
//  UIWalletSend
//
//  Created by Sina on 5/18/23.
//

import Foundation

struct RecentAddress: Codable {
    let address: String
    let addressAlias: String?
    let timstamp: Double
}
