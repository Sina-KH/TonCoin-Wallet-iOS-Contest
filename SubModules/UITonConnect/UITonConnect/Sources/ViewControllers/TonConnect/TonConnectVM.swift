//
//  TonConnectVM.swift
//  UITonConnect
//
//  Created by Sina on 5/9/23.
//

import Foundation
import WalletContext
import WalletCore
import Bridge
import SwiftSignalKit

protocol TonConnectVMDelegate: AnyObject {
    func manifestLoaded(manifest: TonConnectManifest)
    func tonConnected()
    func errorOccured()
}

class TonConnectVM {

    private let walletContext: WalletContext
    private let walletInfo: WalletInfo
    weak var tonConnectVMDelegate: TonConnectVMDelegate?
    init(walletContext: WalletContext,
         walletInfo: WalletInfo,
         tonConnectVMDelegate: TonConnectVMDelegate) {
        self.walletContext = walletContext
        self.walletInfo = walletInfo
        self.tonConnectVMDelegate = tonConnectVMDelegate
    }
    
    private var manifest: TonConnectManifest? = nil

    func loadManifest(url: String) {
        guard let url = URL(string: url) else {
            return
        }
        _ = (Downloader.download(url: url) |> deliverOnMainQueue).start(next: { [weak self] data in
            guard let self else { return }
            manifest = try? JSONDecoder().decode(TonConnectManifest.self, from: data)
            guard let manifest else { return }
            tonConnectVMDelegate?.manifestLoaded(manifest: manifest)
        }, completed: {
        })
    }
    
    func connect(request: TonConnectRequestLink) {
        guard let manifest = manifest else {
            tonConnectVMDelegate?.errorOccured()
            return
        }
        TonConnectCore.connectToApp(url: manifest.url,
                                    walletContext: walletContext,
                                    walletInfo: walletInfo,
                                    appPublicKey: request.id) { [weak self] success in
            self?.tonConnectVMDelegate?.tonConnected()
        }
    }
}
