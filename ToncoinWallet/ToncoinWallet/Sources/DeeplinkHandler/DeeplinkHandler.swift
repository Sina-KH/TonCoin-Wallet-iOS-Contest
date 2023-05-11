//
//  DeeplinkHandler.swift
//  ToncoinWallet
//
//  Created by Sina on 5/11/23.
//

import Foundation
import UIKit
import UITonConnect
import WalletContext

enum Deeplink {
    case tonConnect2(requestLink: TonConnectRequestLink)
}

protocol DeeplinkNavigator: AnyObject {
    func handle(deeplink: Deeplink)
}

class DeeplinkHandler {
    private var deeplinkNavigator: DeeplinkNavigator? = nil
    init(deeplinkNavigator: DeeplinkNavigator) {
        self.deeplinkNavigator = deeplinkNavigator
    }
    
    func handle(_ url: URL) {
        if url.scheme == "tc" {
            handleTonConnect(with: url)
        }
    }
    
    private func handleTonConnect(with url: URL) {
        guard let params = url.queryParameters,
                let versionStr = params["v"],
                let version = Int(versionStr),
                let id = params["id"],
                let r = params["r"]?.removingPercentEncoding?.data(using: .utf8),
                let tonConnectRequestConnect = try? JSONDecoder().decode(TonConnectRequestConnect.self, from: r)
            else { return }

        // Wallet not supports `TonConnect 2` only
        if version != 2 {
            return
        }

        let requestLink = TonConnectRequestLink(version: version, id: id, r: tonConnectRequestConnect)
        deeplinkNavigator?.handle(deeplink: Deeplink.tonConnect2(requestLink: requestLink))
    }
}
