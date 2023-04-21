//
//  ImportWalletVC.swift
//  UICreateWallet
//
//  Created by Sina on 4/21/23.
//

import UIKit
import UIPasscode
import UIComponents
import WalletCore
import WalletContext

class ImportWalletVC: WViewController {

    var walletContext: WalletContext

    private var scrollView: UIScrollView!
    private var wordInputs: [WWordInput]!

    lazy var importWalletVM = ImportWalletVM(importWalletVMDelegate: self)

    public init(walletContext: WalletContext) {
        self.walletContext = walletContext
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

        // hide keyboard on drag
        scrollView.keyboardDismissMode = .interactive

        // add scrollView to view controller's main view
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
                                    title: WStrings.Wallet_WordImport_Title.localized,
                                    description: WStrings.Wallet_WordImport_Text.localized)
        scrollView.addSubview(headerView)
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 0),
            headerView.leftAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.leftAnchor, constant: 32),
            headerView.rightAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.rightAnchor, constant: -32)
        ])

        // `can not remember words` button
        let forgotWordsButton = WButton.setupInstance(.secondary)
        forgotWordsButton.translatesAutoresizingMaskIntoConstraints = false
        forgotWordsButton.setTitle(WStrings.Wallet_WordImport_CanNotRemember.localized, for: .normal)
        forgotWordsButton.addTarget(self, action: #selector(forgotWordsPressed), for: .touchUpInside)
        scrollView.addSubview(forgotWordsButton)
        NSLayoutConstraint.activate([
            forgotWordsButton.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 12),
            forgotWordsButton.leftAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leftAnchor, constant: 48),
            forgotWordsButton.rightAnchor.constraint(equalTo: scrollView.contentLayoutGuide.rightAnchor, constant: -48)
        ])

        // 24 word inputs
        let wordsStackView = UIStackView()
        wordsStackView.translatesAutoresizingMaskIntoConstraints = false
        wordsStackView.axis = .vertical
        wordsStackView.spacing = 16
        scrollView.addSubview(wordsStackView)
        NSLayoutConstraint.activate([
            wordsStackView.topAnchor.constraint(equalTo: forgotWordsButton.bottomAnchor, constant: 36),
            wordsStackView.leftAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leftAnchor, constant: 48),
            wordsStackView.rightAnchor.constraint(equalTo: scrollView.contentLayoutGuide.rightAnchor, constant: -48)
        ])
        let fieldsCount = 24
        wordInputs = []
        let sampleWallet: [String]
        #if DEBUG
        sampleWallet = ["meat", "away", "evoke", "enter", "umbrella", "word", "fly", "project", "unfold", "minor", "wall", "recall",
                        "sadness", "fix", "thumb", "discover", "teach", "beach", "attract", "repeat", "east", "mushroom", "pink", "heart"]
        #else
        sampleWallet = []
        #endif
        for i in 0 ..< fieldsCount {
            let wordInput = WWordInput(wordNumber: i + 1, delegate: self)
            #if DEBUG
            wordInput.textField.text = sampleWallet[i]
            #endif
            if i < fieldsCount - 1 {
                wordInput.textField.returnKeyType = .next
            } else {
                wordInput.textField.returnKeyType = .done
            }
            wordsStackView.addArrangedSubview(wordInput)
            // add word input to word inputs array to have a refrence
            wordInputs.append(wordInput)
        }

        // bottom action
        let continueAction = BottomAction(
            title: WStrings.Wallet_WordCheck_Continue.localized,
            onPress: {
                self.continuePressed()
            }
        )
        
        let bottomActionsView = BottomActionsView(primaryAction: continueAction, reserveSecondaryActionHeight: false)
        scrollView.addSubview(bottomActionsView)
        NSLayoutConstraint.activate([
            bottomActionsView.topAnchor.constraint(equalTo: wordsStackView.bottomAnchor, constant: 16),
            bottomActionsView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -8),
            bottomActionsView.leftAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.leftAnchor, constant: 48),
            bottomActionsView.rightAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.rightAnchor, constant: -48),
        ])

        // listen for keyboard
        WKeyboardObserver.observeKeyboard(delegate: self)
    }
    
    @objc func forgotWordsPressed() {
        navigationController?.pushViewController(RestoreFailedVC(walletContext: walletContext), animated: true)
    }
    
    func continuePressed() {
        view.endEditing(true)

        // check if all the words are in the possibleWordList
        var words = [String]()
        for wordInput in wordInputs {
            guard let word = wordInput.textField.text?.trimmingCharacters(in: .whitespaces).lowercased() else {
                showAlert()
                return
            }
            if !possibleWordList.contains(word) {
                showAlert()
                return
            }
            words.append(word)
        }
        
        importWalletVM.importWallet(walletContext: walletContext, enteredWords: words)
    }
    
    private func showAlert() {
        // a word is incorrect.
        showAlert(title: WStrings.Wallet_WordImport_IncorrectTitle.localized,
                  text: WStrings.Wallet_WordImport_IncorrectText.localized,
                  button: WStrings.Wallet_Alert_OK.localized)
    }
}

extension ImportWalletVC: WKeyboardObserverDelegate {
    func keyboardWillShow(height: CGFloat) {
        scrollView.contentInset.bottom = height + 20
    }
    
    func keyboardWillHide() {
        scrollView.contentInset.bottom = 0
    }
}

extension ImportWalletVC: WWordInputDelegate {
    func resignedFirstResponder() {
        continuePressed()
    }
}

extension ImportWalletVC: ImportWalletVMDelegate {
    func walletImported(walletInfo: ImportedWalletInfo) {
        navigationController?.pushViewController(ImportSuccessVC(walletContext: walletContext, importedWalletInfo: walletInfo), animated: true)
    }
    
    func errorOccured() {
        showAlert()
    }
}
