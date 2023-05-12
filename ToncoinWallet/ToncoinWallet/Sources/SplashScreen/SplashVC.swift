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

        setupViews()
    }

    private var topAnchorConstraint: NSLayoutConstraint!

    private func setupViews() {
        let balanceHeaderBackground = UIView()
        balanceHeaderBackground.translatesAutoresizingMaskIntoConstraints = false
        balanceHeaderBackground.backgroundColor = WTheme.balanceHeaderView.background
        view.addSubview(balanceHeaderBackground)
        topAnchorConstraint = balanceHeaderBackground.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
        NSLayoutConstraint.activate([
            topAnchorConstraint,
            balanceHeaderBackground.leftAnchor.constraint(equalTo: view.leftAnchor),
            balanceHeaderBackground.rightAnchor.constraint(equalTo: view.rightAnchor),
            balanceHeaderBackground.heightAnchor.constraint(equalToConstant: BalanceHeaderView.defaultHeight)
        ])

        let underSafeAreaView = UIView()
        underSafeAreaView.translatesAutoresizingMaskIntoConstraints = false
        underSafeAreaView.backgroundColor = WTheme.balanceHeaderView.background
        view.addSubview(underSafeAreaView)
        NSLayoutConstraint.activate([
            underSafeAreaView.topAnchor.constraint(equalTo: view.topAnchor),
            underSafeAreaView.leftAnchor.constraint(equalTo: view.leftAnchor),
            underSafeAreaView.rightAnchor.constraint(equalTo: view.rightAnchor),
            underSafeAreaView.bottomAnchor.constraint(equalTo: balanceHeaderBackground.topAnchor)
        ])

        let bottomCornersView = ReversedCornerRadiusView()
        bottomCornersView.translatesAutoresizingMaskIntoConstraints = false
        bottomCornersView.backgroundColor = WTheme.balanceHeaderView.background
        view.addSubview(bottomCornersView)
        NSLayoutConstraint.activate([
            bottomCornersView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0),
            bottomCornersView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0),
            bottomCornersView.topAnchor.constraint(equalTo: balanceHeaderBackground.bottomAnchor),
            bottomCornersView.heightAnchor.constraint(equalToConstant: ReversedCornerRadiusView.radius)
        ])
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        
        startApp()
    }

    func replaceVC(with vc: WViewController, animateOutBlackHeader: Bool) {
        let navVC = UINavigationController(rootViewController: vc)
        navVC.modalPresentationStyle = .fullScreen
        navVC.modalTransitionStyle = .crossDissolve
        func presentNav() {
            present(navVC, animated: true) { [weak self] in
                guard let self else {return}
                if let nextDeeplink {
                    self.handle(deeplink: nextDeeplink)
                }
            }
        }
        if animateOutBlackHeader {
            UIView.animate(withDuration: 0.3, animations: {
                self.topAnchorConstraint.constant = -BalanceHeaderView.defaultHeight - self.view.safeAreaInsets.top - 16
                self.view.layoutIfNeeded()
            }) { finished in
                presentNav()
            }
        } else {
            presentNav()
        }
    }
    
    // start the app by initializing the wallet context and getting the wallet info
    private func startApp() {
        splashVM.startApp()
    }
}

extension SplashVC: SplashVMDelegate {
    func navigateToIntro(walletContext: WalletContext) {
        replaceVC(with: IntroVC(walletContext: walletContext), animateOutBlackHeader: true)
    }
    
    func navigateToWalletCreated(walletContext: WalletContext, walletInfo: WalletInfo) {
        replaceVC(with: WalletCreatedVC(walletContext: walletContext, walletInfo: walletInfo, wordList: []), animateOutBlackHeader: true)
    }
    
    func navigateToWalletImported(walletContext: WalletContext, importedWalletInfo: ImportedWalletInfo) {
        replaceVC(with: ImportSuccessVC(walletContext: walletContext, importedWalletInfo: importedWalletInfo), animateOutBlackHeader: true)
    }
    
    func navigateToWalletImported(walletContext: WalletContext, walletInfo: WalletInfo) {
        replaceVC(with: ImportSuccessVC(walletContext: walletContext, walletInfo: walletInfo), animateOutBlackHeader: true)
    }

    func navigateToHome(walletContext: WalletContext, walletInfo: WalletInfo) {
        replaceVC(with: WalletHomeVC(walletContext: walletContext, walletInfo: walletInfo, animateHeaderOnLoad: false), animateOutBlackHeader: false)
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
