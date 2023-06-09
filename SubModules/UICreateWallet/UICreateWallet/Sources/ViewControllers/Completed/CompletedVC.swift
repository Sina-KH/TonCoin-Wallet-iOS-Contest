//
//  CompletedVC.swift
//  UICreateWallet
//
//  Created by Sina on 4/16/23.
//

import UIKit
import UIWalletHome
import UIComponents
import WalletContext
import WalletCore
import SwiftSignalKit

public class CompletedVC: WViewController {

    var walletContext: WalletContext
    var walletInfo: WalletInfo

    public init(walletContext: WalletContext, walletInfo: WalletInfo) {
        self.walletContext = walletContext
        self.walletInfo = walletInfo
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func loadView() {
        super.loadView()
        setupViews()
    }
    
    private var containerView: UIView!
    
    func setupViews() {
        navigationItem.hidesBackButton = true

        containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: view.topAnchor),
            containerView.leftAnchor.constraint(equalTo: view.leftAnchor),
            containerView.rightAnchor.constraint(equalTo: view.rightAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        let viewWalletButton = BottomAction(
            title: WStrings.Wallet_Completed_ViewWallet.localized,
            onPress: {
                self.viewWalletPressed()
            }
        )
        
        let bottomActionsView = BottomActionsView(primaryAction: viewWalletButton)
        containerView.addSubview(bottomActionsView)
        NSLayoutConstraint.activate([
            bottomActionsView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -58),
            bottomActionsView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 48),
            bottomActionsView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -48),
        ])
        
        let topView = UIView()
        topView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(topView)
        NSLayoutConstraint.activate([
            topView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            topView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            topView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            topView.bottomAnchor.constraint(equalTo: bottomActionsView.topAnchor)
        ])

        let headerView = HeaderView(animationName: "Start",
                                    animationPlaybackMode: .loop,
                                    title: WStrings.Wallet_Completed_Title.localized,
                                    description: WStrings.Wallet_Completed_Text.localized)
        topView.addSubview(headerView)
        NSLayoutConstraint.activate([
            headerView.leftAnchor.constraint(equalTo: topView.leftAnchor, constant: 32),
            headerView.rightAnchor.constraint(equalTo: topView.rightAnchor, constant: -32),
            headerView.centerYAnchor.constraint(equalTo: topView.centerYAnchor)
        ])
    }

    func viewWalletPressed() {
        let homeVC = WalletHomeVC(walletContext: walletContext, walletInfo: walletInfo, animateHeaderOnLoad: true)
        let navVC = UINavigationController(rootViewController: homeVC)
        navVC.modalPresentationStyle = .fullScreen
        navVC.modalTransitionStyle = .crossDissolve
        present(navVC, animated: true)
        UIView.animate(withDuration: 0.6) {
            self.containerView.transform = CGAffineTransform(translationX: 0, y: BalanceHeaderView.defaultHeight)
        }
    }
    
    func showAlert() {
        showAlert(title: WStrings.Wallet_Intro_CreateErrorTitle.localized,
                  text: WStrings.Wallet_Intro_CreateErrorText.localized,
                  button: WStrings.Wallet_Alert_OK.localized)
    }
}
