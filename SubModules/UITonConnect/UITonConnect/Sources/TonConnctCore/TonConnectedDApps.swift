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
    
    static func linkedDApps() -> [LinkedDApp] {
        guard let dAppsData = KeychainHelper.dApps()?.data(using: .utf8) else {
            return []
        }
        let dApps = try? JSONDecoder().decode([LinkedDApp].self, from: dAppsData)
        return dApps ?? []
    }
    
    static func saveDApp(dApp: LinkedDApp) {
        var arrDApps = linkedDApps()
        let exists = arrDApps.contains { it in
            it.url == dApp.url
        }
        if !exists {
            arrDApps.append(dApp)
            let dAppsData = try? JSONEncoder().encode(arrDApps)
            if let dAppsData {
                KeychainHelper.save(DApps: String(data: dAppsData, encoding: .utf8)!)
            }
        }
    }
}
