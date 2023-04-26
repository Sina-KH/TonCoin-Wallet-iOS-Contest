//
//  SendConfirmVC.swift
//  UIWalletSend
//
//  Created by Sina on 4/26/23.
//

import UIKit
import UIComponents
import WalletContext
import WalletCore

public class SendConfirmVC: WViewController {
    
    // MARK: - Initializer
    private let walletContext: WalletContext
    private let walletInfo: WalletInfo
    private let addressToSend: String
    private let amount: Int64
    public init(walletContext: WalletContext, walletInfo: WalletInfo, addressToSend: String, amount: Int64) {
        self.walletContext = walletContext
        self.walletInfo = walletInfo
        self.addressToSend = addressToSend
        self.amount = amount
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func loadView() {
        super.loadView()
        setupViews()
    }
    
    private func setupViews() {
        
    }
}
