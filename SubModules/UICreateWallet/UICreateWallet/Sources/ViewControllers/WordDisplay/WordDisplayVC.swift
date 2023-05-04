//
//  WordDisplayVC.swift
//  UICreateWallet
//
//  Created by Sina on 4/14/23.
//

import UIKit
import WalletCore
import WalletContext
import UIWalletHome
import UIComponents

class WordDisplayVC: RecoveryPhraseVC {

    // start time of the word display, to check if user spends enough time
    var startTime: Double

    // User tried to skip too fast, already, or not.
    var notDoneErrorShown = false
    
    override init(walletContext: WalletContext,
         walletInfo: WalletInfo,
         wordList: [String]) {
        self.startTime = Date().timeIntervalSince1970
        super.init(walletContext: walletContext,
                   walletInfo: walletInfo,
                   wordList: wordList)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // called on done button press
    override func donePressed() {
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
