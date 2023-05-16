//
//  TonConnectedDApps.swift
//  UITonConnect
//
//  Created by Sina on 5/16/23.
//

import Foundation
import WalletContext

class TonConnectedDApps {
    private init() {}
    
    static func linkedDApps(walletVersion: Int) -> [LinkedDApp] {
        guard let dAppsData = KeychainHelper.dApps(walletVersion: walletVersion)?.data(using: .utf8) else {
            return []
        }
        let dApps = try? JSONDecoder().decode([LinkedDApp].self, from: dAppsData)
        return dApps ?? []
    }
    
    static func saveDApp(dApp: LinkedDApp, walletVersion: Int) {
        var arrDApps = linkedDApps(walletVersion: walletVersion)
        var found = false
        for (i, it) in arrDApps.enumerated() {
            if it.url == dApp.url {
                arrDApps[i] = dApp
                found = true
                break
            }
        }
        if !found {
            arrDApps.append(dApp)
        }
        let dAppsData = try? JSONEncoder().encode(arrDApps)
        if let dAppsData {
            KeychainHelper.save(DApps: String(data: dAppsData, encoding: .utf8)!, walletVersion: walletVersion)
        }
    }
    
    static func findDApp(walletVersion: Int, publicKey: Data) -> LinkedDApp? {
        return linkedDApps(walletVersion: walletVersion).first { it in
            it.appPublicKey == publicKey
        }
    }
}
