//
//  StartVC.swift
//  UICreateWallet
//
//  Created by Sina on 3/31/23.
//

import UIKit

public class StartVC: UIViewController {

    public override func viewDidLoad() {
        super.viewDidLoad()

        
    }

    @IBAction func createWalletPressed(_ sender: Any) {
        navigationController?.pushViewController(UIViewController(nibName: "WalletCreatedVC",
                                                                  bundle: Bundle(identifier: "org.ton.wallet.UICreateWallet")),
                                                 animated: true)
    }
    
    @IBAction func importWalletPressed(_ sender: Any) {
    }
}
