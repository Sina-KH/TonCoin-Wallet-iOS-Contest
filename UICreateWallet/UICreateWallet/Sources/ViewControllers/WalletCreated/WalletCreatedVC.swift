//
//  WalletCreatedVC.swift
//  UICreateWallet
//
//  Created by Sina on 4/7/23.
//

import UIKit
import WalletCore

class WalletCreatedVC: UIViewController {
    
    var walletContext: WalletContext

    public init(walletContext: WalletContext,
                walletInfo: WalletInfo,
                wordList: [String],
                nibName nibNameOrNil: String?,
                bundle nibBundleOrNil: Bundle?) {
        self.walletContext = walletContext
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.hidesBackButton = true
    }
    
    @IBAction func proceedPressed(_ sender: Any) {
        
    }
    
}
