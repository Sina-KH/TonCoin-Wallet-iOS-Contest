//
//  RecoveryPhraseVC.swift
//  UIWalletHome
//
//  Created by Sina on 5/4/23.
//

import UIKit
import WalletCore
import WalletContext
import UIComponents

open class RecoveryPhraseVC: WViewController {
    
    public var walletContext: WalletContext
    public var walletInfo: WalletInfo
    public var wordList: [String]

    var scrollView: UIScrollView!

    public init(walletContext: WalletContext,
                walletInfo: WalletInfo,
                wordList: [String]) {
        self.walletContext = walletContext
        self.walletInfo = walletInfo
        self.wordList = wordList
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open override func loadView() {
        super.loadView()
        
        setupViews()
    }
    
    func setupViews() {
        // parent scrollView
        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            // scrollView
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leftAnchor.constraint(equalTo: view.leftAnchor),
            scrollView.rightAnchor.constraint(equalTo: view.rightAnchor),
            // contentLayout
            scrollView.contentLayoutGuide.widthAnchor.constraint(equalTo: view.widthAnchor),
        ])

        // header
        let headerView = HeaderView(animationName: "Recovery Phrase",
                                    animationPlaybackMode: .once,
                                    title: WStrings.Wallet_Words_Title.localized,
                                    description: WStrings.Wallet_Words_Text.localized)
        scrollView.addSubview(headerView)
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 0),
            headerView.leftAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.leftAnchor, constant: 32),
            headerView.rightAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.rightAnchor, constant: -32)
        ])

        // word list
        let wordListView = WordListView(words: wordList)
        scrollView.addSubview(wordListView)
        NSLayoutConstraint.activate([
            wordListView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 40),
            wordListView.leftAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.leftAnchor, constant: 45),
            wordListView.rightAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.rightAnchor, constant: -45),
        ])
        
        // bottom actions
        let proceedAction = BottomAction(
            title: WStrings.Wallet_Words_Done.localized,
            onPress: {
                self.donePressed()
            }
        )
        
        let bottomActionsView = BottomActionsView(primaryAction: proceedAction, reserveSecondaryActionHeight: false)
        scrollView.addSubview(bottomActionsView)
        NSLayoutConstraint.activate([
            bottomActionsView.topAnchor.constraint(equalTo: wordListView.bottomAnchor, constant: 52),
            bottomActionsView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -8),
            bottomActionsView.leftAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.leftAnchor, constant: 48),
            bottomActionsView.rightAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.rightAnchor, constant: -48),
        ])

    }

    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // We don't consider additional space under bottomActionsView, to make it fixed without any scroll on bigger iOS devices,
        //  and add this space on smaller devices to let button come up a little more and make user feel better :)
        let isDeviceHeightEnoughForAllContent = UIScreen.main.bounds.height >= scrollView.contentSize.height
        if !isDeviceHeightEnoughForAllContent {
            scrollView.contentInset.bottom = BottomActionsView.reserveHeight
        }
    }
    
    // called on done button press
    open func donePressed() {
        navigationController?.popViewController(animated: true)
    }

}
