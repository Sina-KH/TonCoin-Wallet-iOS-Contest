//
//  WordDisplayVC.swift
//  UICreateWallet
//
//  Created by Sina on 4/14/23.
//

import UIKit
import WalletCore
import WalletContext
import UIComponents

class WordDisplayVC: WViewController {
    
    var walletContext: WalletContext
    var walletInfo: WalletInfo
    var wordList: [String]

    // start time of the word display, to check if user spends enough time
    var startTime: Double

    // User tried to skip too fast, already, or not.
    var notDoneErrorShown = false

    var scrollView: UIScrollView!

    public init(walletContext: WalletContext,
                walletInfo: WalletInfo,
                wordList: [String]) {
        self.walletContext = walletContext
        self.walletInfo = walletInfo
        self.wordList = wordList
        self.startTime = Date().timeIntervalSince1970
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
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
        let headerView = HeaderView(animationName: "WalletWordList",
                                    animationWidth: 132, animationHeight: 132,
                                    animationReply: false,
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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // We don't consider additional space under bottomActionsView, to make it fixed without any scroll on bigger iOS devices,
        //  and add this space on smaller devices to let button come up a little more and make user feel better :)
        let isDeviceHeightEnoughForAllContent = UIScreen.main.bounds.height >= scrollView.contentSize.height
        if !isDeviceHeightEnoughForAllContent {
            scrollView.contentInset.bottom = BottomActionsView.reserveHeight
        }
    }
    
    // called on done button press
    func donePressed() {
        let deltaTime = Date().timeIntervalSince1970 - startTime
        let minimalTimeout: Double
        #if DEBUG
        minimalTimeout = 5.0
        #else
        minimalTimeout = 30.0
        #endif
        if deltaTime < minimalTimeout {
            // it's too soon! show error!
            if !notDoneErrorShown {
                // it's first time, don't show skip button
                showAlert(title: WStrings.Wallet_Words_NotDoneTitle.localized,
                          text: WStrings.Wallet_Words_NotDoneText.localized,
                          button: WStrings.Wallet_Words_NotDoneOk.localized, buttonPressed:  { [weak self] in
                    self?.displayApologiesAcceptedToast()
                })
                notDoneErrorShown = true
            } else {
                // it's second time; let's have a skip button
                showAlert(title: WStrings.Wallet_Words_NotDoneTitle.localized,
                          text: WStrings.Wallet_Words_NotDoneText.localized,
                          button: WStrings.Wallet_Words_NotDoneOk.localized, buttonPressed: { [weak self] in
                    self?.displayApologiesAcceptedToast()
                }, secondaryButton: WStrings.Wallet_Words_NotDoneSkip.localized) { [weak self] in
                    self?.gotoWordCheck()
                }
            }
            return
        }
        
        gotoWordCheck()
    }
    
    func gotoWordCheck() {
        // select 3 random words
        var wordIndices: [Int] = []
        while wordIndices.count < 3 {
            let index = Int(arc4random_uniform(UInt32(wordList.count)))
            if !wordIndices.contains(index) {
                wordIndices.append(index)
            }
        }
        wordIndices.sort()
        
        // pass words to WordCheckVC
        let wordCheckVC = WordCheckVC(walletContext: walletContext,
                                      walletInfo: walletInfo,
                                      wordList: wordList,
                                      wordIndices: wordIndices)
        navigationController?.pushViewController(wordCheckVC, animated: true)
//            strongSelf.push(WalletWordCheckScreen(context: strongSelf.context, blockchainNetwork: strongSelf.blockchainNetwork, mode: .verify(strongSelf.walletInfo, strongSelf.wordList, wordIndices), walletCreatedPreloadState: strongSelf.walletCreatedPreloadState))
    }

    // display apologies accepted toast after error dialog's ok button pressed
    func displayApologiesAcceptedToast() {
//        if self.toastNode != nil {
//            return
//        }
//
//        if let path = getAppBundle().path(forResource: "WalletApologiesAccepted", ofType: "tgs") {
//            let toastNode = ToastNode(theme: self.presentationData.theme, animationPath: path, text: self.presentationData.strings.Wallet_Words_NotDoneResponse)
//            self.toastNode = toastNode
//            if let (layout, _) = self.validLayout {
//                toastNode.update(layout: layout, transition: .immediate)
//            }
//            self.addSubnode(toastNode)
//            toastNode.show(removed: { [weak self, weak toastNode] in
//                guard let strongSelf = self, let toastNode = toastNode else {
//                    return
//                }
//                toastNode.removeFromSupernode()
//                if toastNode === strongSelf.toastNode {
//                    strongSelf.toastNode = nil
//                }
//            })
//        }
    }
}
