//
//  SplashVC.swift
//  UICreateWallet
//
//  Created by Sina on 4/13/23.
//

import UIKit
import UICreateWallet
import UIWalletHome
import UIComponents
import WalletContext
import WalletCore

class SplashVC: WViewController {

    // splash view model, responsible to initialize wallet context and get wallet info
    lazy var splashVM = SplashVM(splashVMDelegate: self)

    public override func loadView() {
        super.loadView()
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        
        // start the app by initializing the wallet context and getting the wallet info
        splashVM.startApp()
    }

    func replaceVC(with vc: UIViewController) {
        navigationController?.setViewControllers([vc], animated: false)
        navigationController?.viewControllers.last?.view.layer.animateAlpha(from: 0.0, to: 1.0, duration: 0.3)
    }
}

extension SplashVC: SplashVMDelegate {
    func navigateToIntro(walletContext: WalletContext) {
        replaceVC(with: IntroVC(walletContext: walletContext))
    }
    
    func navigateToWalletCreated(walletContext: WalletContext, walletInfo: WalletInfo) {
        replaceVC(with: WalletCreatedVC(walletContext: walletContext, walletInfo: walletInfo, wordList: []))
    }
    
    func navigateToWalletImported(walletContext: WalletContext, importedWalletInfo: ImportedWalletInfo) {
        replaceVC(with: ImportSuccessVC(walletContext: walletContext, importedWalletInfo: importedWalletInfo))
    }
    
    func navigateToWalletImported(walletContext: WalletContext, walletInfo: WalletInfo) {
        replaceVC(with: ImportSuccessVC(walletContext: walletContext, walletInfo: walletInfo))
    }

    func navigateToHome(walletContext: WalletContext, walletInfo: WalletInfo) {
        replaceVC(with: WalletHomeVC(walletContext: walletContext, walletInfo: walletInfo))
    }
    
    func errorOccured() {
        
    }
}
