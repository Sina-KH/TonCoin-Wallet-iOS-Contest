//
//  WalletCreatedVC.swift
//  UICreateWallet
//
//  Created by Sina on 4/7/23.
//

import UIKit
import WalletCore
import WalletContext
import UIComponents
import UIPasscode

public class WalletCreatedVC: WViewController {
    
    var walletContext: WalletContext
    var walletInfo: WalletInfo
    var wordList: [String]

    lazy var walletCreatedVM = WalletCreatedVM(walletCreatedVMDelegate: self)

    public init(walletContext: WalletContext,
                walletInfo: WalletInfo,
                wordList: [String]) {
        self.walletContext = walletContext
        self.walletInfo = walletInfo
        self.wordList = wordList
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func loadView() {
        super.loadView()
        setupViews()
    }
    
    private var bottomActionsView: BottomActionsView!

    func setupViews() {
        navigationItem.hidesBackButton = true

        let proceedAction = BottomAction(
            title: WStrings.Wallet_Created_Proceed.localized,
            onPress: {
                self.proceedPressed()
            }
        )
        
        bottomActionsView = BottomActionsView(primaryAction: proceedAction)
        view.addSubview(bottomActionsView)
        NSLayoutConstraint.activate([
            bottomActionsView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -58),
            bottomActionsView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 48),
            bottomActionsView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -48),
        ])
        
        let topView = UIView()
        topView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(topView)
        NSLayoutConstraint.activate([
            topView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            topView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            topView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            topView.bottomAnchor.constraint(equalTo: bottomActionsView.topAnchor)
        ])

        let headerView = HeaderView(animationName: "Congratulations",
                                    animationPlaybackMode: .once,
                                    title: WStrings.Wallet_Created_Title.localized,
                                    description: WStrings.Wallet_Created_Text.localized)
        topView.addSubview(headerView)
        NSLayoutConstraint.activate([
            headerView.leftAnchor.constraint(equalTo: topView.leftAnchor, constant: 32),
            headerView.rightAnchor.constraint(equalTo: topView.rightAnchor, constant: -32),
            headerView.centerYAnchor.constraint(equalTo: topView.centerYAnchor)
        ])
    }

    func proceedPressed() {
        if wordList.isEmpty {
            walletCreatedVM.loadWords(walletContext: walletContext, walletInfo: walletInfo)
            return
        }
        let wordDisplayVC = WordDisplayVC(walletContext: walletContext,
                                          walletInfo: walletInfo,
                                          wordList: wordList)
        navigationController?.pushViewController(wordDisplayVC, animated: true)
    }
    
    var isLoading: Bool = false {
        didSet {
            bottomActionsView.primaryButton.showLoading = isLoading
            view.isUserInteractionEnabled = !isLoading
        }
    }
    
}

extension WalletCreatedVC: WalletCreatedVMDelegate {

    func wordsLoaded(words: [String]) {
        self.wordList = words
        proceedPressed()
    }
    
    func errorOccured() {
        showAlert(title: WStrings.Wallet_Created_ExportErrorTitle.localized,
                  text: WStrings.Wallet_Created_ExportErrorText.localized,
                  button: WStrings.Wallet_Alert_OK.localized)
    }

}
