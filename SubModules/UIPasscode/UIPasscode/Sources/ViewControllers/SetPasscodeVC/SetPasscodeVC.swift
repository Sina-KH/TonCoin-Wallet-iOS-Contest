//
//  SetPasscodeVC.swift
//  UIPasscode
//
//  Created by Sina on 4/16/23.
//

import UIKit
import UIComponents
import WalletCore
import WalletContext

public class SetPasscodeVC: WViewController {
    
    var walletContext: WalletContext
    var walletInfo: WalletInfo
    var onCompletion: () -> Void

    public init(walletContext: WalletContext,
                walletInfo: WalletInfo,
                onCompletion: @escaping () -> Void) {
        self.walletContext = walletContext
        self.walletInfo = walletInfo
        self.onCompletion = onCompletion
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var headerView: HeaderView!
    var passcodeInputView: PasscodeInputView!
    var passcodeOptionsView: PasscodeOptionsView!
    var bottomConstraint: NSLayoutConstraint!

    public static let passcodeOptionsFromBottom = CGFloat(8)
    
    public override func loadView() {
        super.loadView()
        setupViews()
    }
    
    func setupViews() {
        // top animation and header
        let topView = UIView()
        topView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(topView)
        NSLayoutConstraint.activate([
            topView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            topView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            topView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor)
        ])

        headerView = HeaderView(animationName: "Password",
                                    animationPlaybackMode: .toggle(false),
                                    title: WStrings.Wallet_SetPasscode_Title.localized,
                                    description: WStrings.Wallet_SetPasscode_Text(digits:
                                                                                  PasscodeInputView.defaultPasscodeLength))
        topView.addSubview(headerView)
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: topView.topAnchor, constant: 46),
            headerView.centerXAnchor.constraint(equalTo: topView.centerXAnchor),
            headerView.bottomAnchor.constraint(equalTo: topView.bottomAnchor)
        ])

        // setup passcode input view
        passcodeInputView = PasscodeInputView(delegate: self)
        passcodeInputView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(passcodeInputView)
        NSLayoutConstraint.activate([
            passcodeInputView.topAnchor.constraint(equalTo: topView.bottomAnchor, constant: 40),
            passcodeInputView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        passcodeInputView.becomeFirstResponder()
        
        // setup passcode options button
        let passcodeOptionsButton = WButton.setupInstance(.secondary)
        passcodeOptionsButton.translatesAutoresizingMaskIntoConstraints = false
        passcodeOptionsButton.setTitle(WStrings.Wallet_SetPasscode_Options.localized, for: .normal)
        passcodeOptionsButton.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        passcodeOptionsButton.addTarget(self, action: #selector(passcodeOptionsPressed), for: .touchUpInside)
        view.addSubview(passcodeOptionsButton)
        bottomConstraint = passcodeOptionsButton.bottomAnchor.constraint(equalTo: view.bottomAnchor,
                                                                         constant: -SetPasscodeVC.passcodeOptionsFromBottom)
        NSLayoutConstraint.activate([
            bottomConstraint,
            passcodeOptionsButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])

        // listen for keyboard
        WKeyboardObserver.observeKeyboard(delegate: self)

        // passcode options view
        passcodeOptionsView = PasscodeOptionsView(delegate: self)
        view.addSubview(passcodeOptionsView)
        NSLayoutConstraint.activate([
            passcodeOptionsView.bottomAnchor.constraint(equalTo: passcodeOptionsButton.topAnchor),
            passcodeOptionsView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backgroundPressed)))
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    @objc func passcodeOptionsPressed() {
        passcodeOptionsView.toggle()
    }
    
    @objc func backgroundPressed() {
        if passcodeOptionsView.visibility {
            passcodeOptionsView.toggle()
        }
    }
    
    // Called from ConfirmPasscodeVC when passcode is wrong
    func passcodesDoNotMatch() {
        headerView.lblDescription.text = WStrings.Wallet_SetPasscode_PasscodesDoNotMatch.localized
        passcodeInputView.becomeFirstResponder()
    }
}

extension SetPasscodeVC: PasscodeInputViewDelegate {
    func passcodeChanged(passcode: String) {
        headerView.animatedSticker?.toggle(!passcode.isEmpty)
    }
    func passcodeSelected(passcode: String) {
        // push `ConfirmPasscode` view controller
        let confirmPasscodeVC = ConfirmPasscodeVC(walletContext: walletContext,
                                                  walletInfo: walletInfo,
                                                  onCompletion: onCompletion,
                                                  setPasscodeVC: self,
                                                  selectedPasscode: passcode)
        navigationController?.pushViewController(confirmPasscodeVC,
                                                 animated: true,
                                                 completion: { [weak self] in
            // make passcode empty on completion
            self?.passcodeInputView.currentPasscode = ""
        })
    }
}

extension SetPasscodeVC: WKeyboardObserverDelegate {
    public func keyboardWillShow(height: CGFloat) {
        bottomConstraint.constant = -height - SetPasscodeVC.passcodeOptionsFromBottom
    }
    
    public func keyboardWillHide() {
        bottomConstraint.constant = -SetPasscodeVC.passcodeOptionsFromBottom
    }
}

extension SetPasscodeVC: PasscodeOptionsViewDelegate {
    func passcodeOptionsDigitSelected(digits: Int) {
        passcodeInputView.setCirclesCount(to: digits)
        headerView.lblDescription.text = WStrings.Wallet_SetPasscode_Text(digits: digits)
    }
}
