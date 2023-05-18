//
//  RecentAddressesHelpers.swift
//  UIWalletSend
//
//  Created by Sina on 5/18/23.
//

import Foundation
import WalletContext

class RecentAddressesHelpers {
    private init() {}
    
    static func recentAddresses(walletVersion: Int) -> [RecentAddress] {
        guard let recentAddressesData = KeychainHelper.recentAddresses(walletVersion: walletVersion)?.data(using: .utf8) else {
            return []
        }
        let recentAddresses = try? JSONDecoder().decode([RecentAddress].self, from: recentAddressesData)
        return recentAddresses ?? []
    }
    
    static func saveRecentAddress(recentAddress: RecentAddress, walletVersion: Int) {
        var arrRecents = recentAddresses(walletVersion: walletVersion)
        arrRecents.removeAll { it in
            it.address == recentAddress.address && it.addressAlias == recentAddress.addressAlias
        }
        arrRecents.append(recentAddress)
        let arrRecentsData = try? JSONEncoder().encode(arrRecents)
        if let arrRecentsData {
            KeychainHelper.save(recentAddresses: String(data: arrRecentsData, encoding: .utf8)!, walletVersion: walletVersion)
        }
    }
    
    static func clearRecentAddresses(walletVersion: Int) {
        KeychainHelper.save(recentAddresses: nil, walletVersion: walletVersion)
    }
}
