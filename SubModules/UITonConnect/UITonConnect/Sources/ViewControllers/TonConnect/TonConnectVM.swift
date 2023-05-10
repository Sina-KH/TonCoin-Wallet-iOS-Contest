//
//  TonConnectVM.swift
//  UITonConnect
//
//  Created by Sina on 5/9/23.
//

import Foundation
import WalletContext
import SwiftSignalKit

protocol TonConnectVMDelegate: AnyObject {
    func manifestLoaded(manifest: TonConnectManifest)
    func errorOccured()
}

class TonConnectVM {

    weak var tonConnectVMDelegate: TonConnectVMDelegate?
    init(tonConnectVMDelegate: TonConnectVMDelegate) {
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
    
    func connect() {
        
    }
}
