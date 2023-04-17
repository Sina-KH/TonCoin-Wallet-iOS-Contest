//
//  ConfirmPasscodeVC.swift
//  UIPasscode
//
//  Created by Sina on 4/17/23.
//

import UIKit
import UIComponents
import WalletContext

public class ConfirmPasscodeVC: WViewController {

    private var selectedPasscode: String!
    private weak var setPasscodeVC: SetPasscodeVC? = nil

    var headerView: HeaderView!
    var passcodeInputView: PasscodeInputView!
    var passcodeOptionsView: PasscodeOptionsView!
    var bottomConstraint: NSLayoutConstraint!

    public static let passcodeOptionsFromBottom = CGFloat(8)

    public init(setPasscodeVC: SetPasscodeVC, selectedPasscode: String) {
        super.init(nibName: nil, bundle: nil)
        self.setPasscodeVC = setPasscodeVC
        self.selectedPasscode = selectedPasscode
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

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
                                    animationWidth: 124, animationHeight: 124,
                                    animationPlaybackMode: .toggle(false),
                                    title: WStrings.Wallet_ConfirmPasscode_Title.localized,
                                    description: WStrings.Wallet_ConfirmPasscode_Text(digits:
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
        let passcodeOptionsButton = WButtonSecondary(type: .system)
        passcodeOptionsButton.translatesAutoresizingMaskIntoConstraints = false
        passcodeOptionsButton.setup()
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
}

extension ConfirmPasscodeVC: PasscodeInputViewDelegate {
    func passcodeChanged(passcode: String) {
        headerView.animatedSticker.toggle(!passcode.isEmpty)
    }
    func passcodeSelected(passcode: String) {
        if passcode != selectedPasscode {
            // wrong passcode, return to setPasscodeVC
            setPasscodeVC?.passcodesDoNotMatch()
            navigationController?.popViewController(animated: true)
            return
        }
        navigationController?.pushViewController(ActivateBiometricVC(), animated: true)
    }
}

extension ConfirmPasscodeVC: WKeyboardObserverDelegate {
    public func keyboardWillShow(height: CGFloat) {
        bottomConstraint.constant = -height - SetPasscodeVC.passcodeOptionsFromBottom
    }
    
    public func keyboardWillHide() {
        bottomConstraint.constant = -SetPasscodeVC.passcodeOptionsFromBottom
    }
}
