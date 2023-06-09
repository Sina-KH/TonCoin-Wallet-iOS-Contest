//
//  WordCheckVC.swift
//  UICreateWallet
//
//  Created by Sina on 4/14/23.
//

import UIKit
import UIPasscode
import UIComponents
import WalletCore
import WalletContext

class WordCheckVC: WViewController {

    var walletContext: WalletContext
    var walletInfo: WalletInfo
    var wordList: [String]
    var wordIndices: [Int]

    private var scrollView: UIScrollView!
    private var wordInputs: [WWordInput]!

    public init(walletContext: WalletContext,
                walletInfo: WalletInfo,
                wordList: [String],
                wordIndices: [Int]) {
        self.walletContext = walletContext
        self.walletInfo = walletInfo
        self.wordList = wordList
        self.wordIndices = wordIndices
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
        let headerView = HeaderView(animationName: "Test Time",
                                    animationPlaybackMode: .once,
                                    title: WStrings.Wallet_WordCheck_Title.localized,
                                    description: WStrings.Wallet_WordCheck_ViewWords(wordIndices: wordIndices))
        scrollView.addSubview(headerView)
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 0),
            headerView.leftAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.leftAnchor, constant: 32),
            headerView.rightAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.rightAnchor, constant: -32)
        ])

        // 3 word inputs
        let wordsStackView = UIStackView()
        wordsStackView.translatesAutoresizingMaskIntoConstraints = false
        wordsStackView.axis = .vertical
        wordsStackView.spacing = 16
        scrollView.addSubview(wordsStackView)
        NSLayoutConstraint.activate([
            wordsStackView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 36),
            wordsStackView.leftAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leftAnchor, constant: 48),
            wordsStackView.rightAnchor.constraint(equalTo: scrollView.contentLayoutGuide.rightAnchor, constant: -48)
        ])
        let fieldsCount = 3
        wordInputs = []
        for i in 0 ..< fieldsCount {
            let wordInput = WWordInput(index: i, wordNumber: wordIndices[i] + 1, delegate: self)
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
    
    func continuePressed() {
        for (i, index) in wordIndices.enumerated() {
            if wordInputs[i].textField.text?.trimmingCharacters(in: .whitespaces).lowercased() != wordList[index] {
                view.endEditing(true)
                showAlert()
                return
            }
        }
        // all the words are correct
        let nextVC = BiometricHelper.biometricType() == .none ?
        CompletedVC(walletContext: walletContext, walletInfo: walletInfo) :
        SetPasscodeVC(walletContext: walletContext, walletInfo: walletInfo, onCompletion: { [weak self] in
            guard let self else {return}
            // set passcode flow completion
            // update wallet core state
            _ = confirmWalletExported(storage: walletContext.storage, publicKey: walletInfo.publicKey).start()
            // navigate to completed vc
            navigationController?.pushViewController(CompletedVC(walletContext: walletContext, walletInfo: walletInfo), animated: true)
        })

        navigationController?.pushViewController(nextVC, animated: true)
    }
    
    private func showAlert() {
        // a word is incorrect.
        showAlert(title: WStrings.Wallet_WordCheck_IncorrectHeader.localized,
                  text: WStrings.Wallet_WordCheck_IncorrectText.localized,
                  button: WStrings.Wallet_WordCheck_TryAgain.localized,
                  secondaryButton: WStrings.Wallet_WordCheck_ViewWords.localized,
                  secondaryButtonPressed: { [weak self] in
            // see words pressed
            self?.navigationController?.popViewController(animated: true)
        }, preferPrimary: false)
    }
}

extension WordCheckVC: WKeyboardObserverDelegate {
    func keyboardWillShow(height: CGFloat) {
        if scrollView.contentInset.bottom == 0 {
            scrollView.contentInset.bottom = height + 20
        } else {
            // it's just a keyboard height changed caused by pushing new vc with keyboard
        }
    }
    
    func keyboardWillHide() {
        scrollView.contentInset.bottom = 0
    }
}

extension WordCheckVC: WWordInputDelegate {
    func resignedFirstResponder() {
        continuePressed()
    }
}
