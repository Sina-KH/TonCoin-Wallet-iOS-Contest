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
import UIWalletSend
import UIComponents
import WalletContext
import WalletCore
import SwiftSignalKit
import UIPasscode

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
    private var heightAnchorConstraint: NSLayoutConstraint!

    private func setupViews() {
        let balanceHeaderBackground = UIView()
        balanceHeaderBackground.translatesAutoresizingMaskIntoConstraints = false
        balanceHeaderBackground.backgroundColor = WTheme.balanceHeaderView.background
        view.addSubview(balanceHeaderBackground)
        topAnchorConstraint = balanceHeaderBackground.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
        heightAnchorConstraint = balanceHeaderBackground.heightAnchor.constraint(equalToConstant: BalanceHeaderView.defaultHeight)
        NSLayoutConstraint.activate([
            topAnchorConstraint,
            balanceHeaderBackground.leftAnchor.constraint(equalTo: view.leftAnchor),
            balanceHeaderBackground.rightAnchor.constraint(equalTo: view.rightAnchor),
            heightAnchorConstraint
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
    
    private var firstTime = true
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if firstTime {
            firstTime = false
            afterUnlock { [weak self] in
                self?.splashVM.startApp()
            }
        }
    }

    func replaceVC(with vc: WViewController, animateOutBlackHeader: Bool, animated: Bool = true) {
        let navVC = UINavigationController(rootViewController: vc)
        navVC.modalPresentationStyle = .fullScreen
        navVC.modalTransitionStyle = .crossDissolve
        func presentNav() {
            present(navVC, animated: animated)
        }
        if animateOutBlackHeader {
            UIView.animate(withDuration: 0.2, animations: {
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

    // present unlockVC if required and continue tasks assigned, after unlock
    func afterUnlock(completion: @escaping () -> Void) {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate

        if appDelegate?.appUnlocked ?? false {
            completion()
            return
        }

        if KeychainHelper.passcode() != nil && KeychainHelper.isAppLockActivated() {
            // should unlock
            let unlockVC = UnlockVC(animatedPresentation: true) {
                // unlocked, animate back and load
                UIView.animate(withDuration: 0.2) { [weak self] in
                    self?.heightAnchorConstraint.constant = BalanceHeaderView.defaultHeight
                    self?.view.layoutIfNeeded()
                } completion: { _ in
                    appDelegate?.appUnlocked = true
                    completion()
                }
            }
            unlockVC.modalPresentationStyle = .fullScreen
            // present unlock animated
            UIView.animate(withDuration: 0.2, delay: 0.1, animations: { [weak self] in
                guard let self else { return }
                heightAnchorConstraint.constant = view.frame.height
                view.layoutIfNeeded()
            }) { [weak self] _ in
                self?.present(unlockVC, animated: false, completion: {
                    // try biometric unlock after appearance of the `UnlockVC`
                    unlockVC.tryBiometric()
                })
            }
        } else {
            // app is not locked
            appDelegate?.appUnlocked = true
            completion()
        }
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
        replaceVC(with: WalletHomeVC(walletContext: walletContext, walletInfo: walletInfo, animateHeaderOnLoad: false), animateOutBlackHeader: false, animated: false)
    }
    
    func openTonConnectTransfer(walletContext: WalletContext,
                                walletInfo: WalletInfo,
                                dApp: LinkedDApp,
                                requestID: Int64,
                                address: String,
                                amount: Int64) {
        let tonTransferVC = TonTransferVC(walletContext: walletContext,
                                          walletInfo: walletInfo,
                                          dApp: dApp,
                                          requestID: requestID,
                                          addressToSend: address,
                                          amount: amount)
        var topVC = topViewController()
        if let navVC = topVC as? UINavigationController {
            topVC = navVC.topViewController
        }
        if let topVC = topVC as? WViewController {
            topVC.present(bottomSheet: tonTransferVC)
        } else {
            topVC?.present(tonTransferVC, animated: true)
        }
    }
    
    func navigateToSetPasscode() {
        // TODO:: should be called if original version updated to this version, to have a passcode!
    }
    
    func navigateToSecuritySettingsChanged(walletContext: WalletContext, type: SecuritySettingsChangedType) {
        replaceVC(with: SecuritySettingsChangedVC(walletContext: walletContext, changeType: type), animateOutBlackHeader: true)
    }
    
    func errorOccured() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.splashVM.startApp()
        }
    }

    // this function is called from wallet context implementation, after home vc opens up, to handle deeplinks and connect to DApps
    func setWalletReadyWalletInfo(walletInfo: WalletCore.WalletInfo) {
        splashVM.readyWalletInfo = walletInfo
        if let nextDeeplink {
            DispatchQueue.main.async {
                self.handle(deeplink: nextDeeplink)
            }
        }
        // connect the application to the wallet applications
        //  it generates new keys if not exists (or deleted before)
        //  connection requests are only processed if the app is ready and wallet is connected.
        TonConnectCore.shared.startBridgeConnection(walletInfo: walletInfo)
    }
    
    func dismissAll(completion: @escaping () -> Void) {
        if topViewController() !== self {
            dismiss(animated: true) {
                completion()
            }
        }
    }
    
    func restartApp() {
        if topViewController() !== self {
            dismiss(animated: true) { [weak self] in
                self?.startApp()
            }
        } else {
            startApp()
        }
    }
}

// MARK: - Navigate to deeplink target screens
extension SplashVC: DeeplinkNavigator {
    func handle(deeplink: Deeplink) {
        if splashVM.appStarted {
            guard let walletInfo = splashVM.readyWalletInfo else {
                // we ignore depplinks when wallet is not ready yet, wallet gets ready when home page appears
                nextDeeplink = nil
                return
            }

            switch deeplink {

                // tonConnect2 request deeplink
                case .tonConnect2(requestLink: let requestLink):
                let tonConnectVC = TonConnectVC(walletContext: splashVM.walletContext!,
                                           walletInfo: walletInfo,
                                           tonConnectRequestLink: requestLink)
                
                afterUnlock {
                    var topVC = topViewController()
                    if let navVC = topVC as? UINavigationController {
                        topVC = navVC.topViewController
                    }
                    if let topVC = topVC as? WViewController {
                        topVC.present(bottomSheet: tonConnectVC)
                    } else {
                        topVC?.present(tonConnectVC, animated: true)
                    }
                }
                break
                
            case .invoice(address: let address, amount: let amount, comment: let comment):
                let nav = UINavigationController()
                let sendVC = SendVC(walletContext: splashVM.walletContext!,
                                    walletInfo: walletInfo,
                                    balance: nil,
                                    defaultAddress: address)
                ContextAddressHelpers.toBase64Address(unknownAddress: address,
                                                      walletContext: splashVM.walletContext!) { [weak self] addressBase64 in
                    guard let self, let addressBase64 else {
                        return
                    }
                    let sendAmountVC = SendAmountVC(walletContext: splashVM.walletContext!,
                                                    walletInfo: walletInfo,
                                                    addressToSend: addressBase64,
                                                    balance: nil,
                                                    addressAlias: addressBase64 == address.base64URLEscaped() ? nil : address)
                    if let amount = amount {
                        let sendConfirmVC = SendConfirmVC(walletContext: splashVM.walletContext!,
                                                    walletInfo: walletInfo,
                                                    addressToSend: address,
                                                    amount: amount,
                                                    defaultComment: comment)
                        nav.viewControllers = [sendVC, sendAmountVC, sendConfirmVC]
                    } else {
                        nav.viewControllers = [sendVC, sendAmountVC]
                    }
                    afterUnlock {
                        topViewController()?.present(nav, animated: true)
                    }
                }
                break

            }

            nextDeeplink = nil
        } else {
            nextDeeplink = deeplink
        }
    }
}
