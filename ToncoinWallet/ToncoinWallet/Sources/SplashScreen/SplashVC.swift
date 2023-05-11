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
    
    // if app is loading, the deeplink will be stored here to be handle after app started.
    private var nextDeeplink: Deeplink? = nil

    public override func loadView() {
        super.loadView()
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        
        startApp()
    }

    func replaceVC(with vc: WViewController) {
        let navVC = UINavigationController(rootViewController: vc)
        navVC.modalPresentationStyle = .fullScreen
        present(navVC, animated: false) { [weak self] in
            guard let self else {return}
            if let nextDeeplink {
                self.handle(deeplink: nextDeeplink)
            }
        }
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

// MARK: - Navigate to deeplink target screens
extension SplashVC: DeeplinkNavigator {
    func handle(deeplink: Deeplink) {
        if splashVM.appStarted {
            switch deeplink {

                // tonConnect2 request deeplink
                case .tonConnect2(requestLink: let requestLink):
                    var topVC = topViewController()
                    if let navVC = topVC as? UINavigationController {
                        topVC = navVC.topViewController
                    }
                    if let readyWalletInfo = splashVM.readyWalletInfo {
                        if let topVC = topVC as? WViewController {
                            topVC.present(bottomSheet: TonConnectVC(walletContext: splashVM.walletContext!,
                                                                    walletInfo: readyWalletInfo,
                                                                    tonConnectRequestLink: requestLink))
                        }
                    }

            }
            nextDeeplink = nil
        } else {
            nextDeeplink = deeplink
        }
    }
}
