//
//  SplashVC.swift
//  UICreateWallet
//
//  Created by Sina on 4/13/23.
//

import UIKit
import UICreateWallet
import UIWalletHome
import UITonConnect
import UIComponents
import WalletContext
import WalletCore
import SwiftSignalKit

class SplashVC: WViewController {

    // splash view model, responsible to initialize wallet context and get wallet info
    lazy var splashVM = SplashVM(splashVMDelegate: self)

    public override func loadView() {
        super.loadView()
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        
        startApp()
    }

    func replaceVC(with vc: UIViewController) {
        let navVC = UINavigationController(rootViewController: vc)
        navVC.modalPresentationStyle = .fullScreen
        present(navVC, animated: false)
        vc.view.layer.animateAlpha(from: 0.0, to: 1.0, duration: 0.3)
    }
    
    // start the app by initializing the wallet context and getting the wallet info
    private func startApp() {
        splashVM.startApp()
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
    
    func navigateToSetPasscode() {
        // TODO:: should be called if original version updated to this version, to have a passcode!
    }
    
    func errorOccured() {
        // TODO::
    }
    
    func restartApp() {
        dismiss(animated: true) { [weak self] in
            self?.startApp()
        }
    }
}
