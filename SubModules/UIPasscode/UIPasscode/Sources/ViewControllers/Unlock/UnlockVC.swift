//
//  UnlockVC.swift
//  UIPasscode
//
//  Created by Sina on 4/28/23.
//

import UIKit
import UIComponents
import WalletContext
import LocalAuthentication

public class UnlockVC: WViewController {
    
    private var onAuth: () -> Void
    public init(onAuth: @escaping () -> Void) {
        self.onAuth = onAuth
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func loadView() {
        super.loadView()
        setupViews()
    }
    
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    private var passcodeInputView: PasscodeInputView!

    private func setupViews() {
        view.backgroundColor = WTheme.balanceHeaderView.background
        
        let unlockView = UIStackView()
        unlockView.translatesAutoresizingMaskIntoConstraints = false
        unlockView.axis = .vertical
        unlockView.alignment = .center
        view.addSubview(unlockView)
        NSLayoutConstraint.activate([
            unlockView.leftAnchor.constraint(equalTo: view.leftAnchor),
            unlockView.rightAnchor.constraint(equalTo: view.rightAnchor),
            unlockView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        // gem icon
        let gemIcon = UIImageView(image: UIImage(named: "SendGem")!)
        gemIcon.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            gemIcon.widthAnchor.constraint(equalToConstant: 48),
            gemIcon.heightAnchor.constraint(equalToConstant: 48)
        ])
        unlockView.addArrangedSubview(gemIcon)

        // gap
        unlockView.setCustomSpacing(isIPhone5s ? 16 : 29, after: gemIcon)

        // enter passcode hint
        let enterPasscodeLabel = UILabel()
        enterPasscodeLabel.translatesAutoresizingMaskIntoConstraints = false
        enterPasscodeLabel.font = .systemFont(ofSize: isIPhone5s ? 17 : 20)
        enterPasscodeLabel.text = WStrings.Wallet_Unlock_Title.localized
        enterPasscodeLabel.textColor = WTheme.balanceHeaderView.balance
        unlockView.addArrangedSubview(enterPasscodeLabel)
        
        // gap
        unlockView.setCustomSpacing(isIPhone5s ? 12 : 24, after: enterPasscodeLabel)

        // passcode input view
        passcodeInputView = PasscodeInputView(delegate: self, theme: WTheme.unlockPasscodeInput)
        passcodeInputView.isUserInteractionEnabled = false
        unlockView.addArrangedSubview(passcodeInputView)

        // gap
        unlockView.setCustomSpacing(isIPhone5s ? 24 : 61, after: passcodeInputView)

        // create and add buttons
        // we have 4 rows
        for r in 0 ... 3 {
            let rowView = UIStackView()
            rowView.translatesAutoresizingMaskIntoConstraints = false
            rowView.spacing = isIPhone5s ? 8 : 24
            rowView.distribution = .equalCentering
            // each row contains 3 columns
            for c in 1 ... 3 {
                let button = WBaseButton(type: .system)
                button.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    button.widthAnchor.constraint(equalToConstant: 78),
                    button.heightAnchor.constraint(equalToConstant: 78)
                ])
                button.layer.cornerRadius = 39
                button.backgroundColor = WTheme.background.withAlphaComponent(0.12)
                button.highlightBackgroundColor = WTheme.background.withAlphaComponent(0.4)
                button.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
                button.tag = r * 3 + c
                // check if button should contain a number label on top and a alphabet label on bottom
                if r < 3 || c == 2 {
                    // numbers 0 to 9
                    let buttonTitleLabel = UILabel()
                    buttonTitleLabel.translatesAutoresizingMaskIntoConstraints = false
                    buttonTitleLabel.font = .boldSystemFont(ofSize: 37)
                    buttonTitleLabel.textColor = WTheme.background
                    let num: Int
                    if r < 3 {
                        // numbers between 1 and 9
                        num = r * 3 + c
                    } else {
                        // number 0
                        num = 0
                    }
                    buttonTitleLabel.text = "\(num)"
                    button.addSubview(buttonTitleLabel)
                    NSLayoutConstraint.activate([
                        buttonTitleLabel.heightAnchor.constraint(equalToConstant: 32),
                        buttonTitleLabel.centerXAnchor.constraint(equalTo: button.centerXAnchor),
                        buttonTitleLabel.centerYAnchor.constraint(equalTo: button.centerYAnchor, constant: -6)
                    ])
                    let buttonAlphabetLabel = UILabel()
                    buttonAlphabetLabel.translatesAutoresizingMaskIntoConstraints = false
                    buttonAlphabetLabel.font = .boldSystemFont(ofSize: num > 0 ? 10 : 16)
                    buttonAlphabetLabel.textColor = WTheme.background
                    buttonAlphabetLabel.text = alphabetText(forNum: num)
                    button.addSubview(buttonAlphabetLabel)
                    NSLayoutConstraint.activate([
                        buttonAlphabetLabel.centerXAnchor.constraint(equalTo: button.centerXAnchor),
                        buttonAlphabetLabel.topAnchor.constraint(equalTo: buttonTitleLabel.bottomAnchor, constant: num > 0 ? 1 : -4)
                    ])
                } else {
                    let image: UIImage
                    if c == 1 {
                        // touchID / faceID
                        let biometricType = BiometricHelper.biometricType()
                        if biometricType == .face {
                            image = UIImage(named: "FaceIDIcon")!
                        } else {
                            image = UIImage(named: "TouchIDIcon")!
                        }
                    } else {
                        // backspace!
                        image = UIImage(named: "BackspaceIcon")!
                    }
                    let buttonImageView = UIImageView(image: image.withRenderingMode(.alwaysTemplate))
                    buttonImageView.tintColor = WTheme.balanceHeaderView.balance
                    buttonImageView.translatesAutoresizingMaskIntoConstraints = false
                    buttonImageView.contentMode = .scaleAspectFit
                    button.addSubview(buttonImageView)
                    NSLayoutConstraint.activate([
                        // backspace should be a little left!
                        buttonImageView.centerXAnchor.constraint(equalTo: button.centerXAnchor, constant: c == 3 ? -1 : 0),
                        buttonImageView.centerYAnchor.constraint(equalTo: button.centerYAnchor),
                        buttonImageView.heightAnchor.constraint(equalToConstant: 32)
                    ])
                }
                rowView.addArrangedSubview(button)
            }
            let gapView = UIView()
            gapView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                gapView.widthAnchor.constraint(equalToConstant: 0),
                gapView.heightAnchor.constraint(equalToConstant: isIPhone5s ? 6 : 18)
            ])
            unlockView.addArrangedSubview(gapView)
            unlockView.addArrangedSubview(rowView)
        }
    }
    
    private func alphabetText(forNum num: Int) -> String {
        switch num {
        case 0:
            return "+"
        case 1:
            return ""
        case 7:
            return "P Q R S"
        case 8:
            return "T U V"
        case 9:
            return "W X Y Z"
        default:
            var txt = ""
            let startIndex = Int(UnicodeScalar("A").value) + num * 3 - 6
            for charIndex in startIndex ... startIndex + 2 {
                let char = String(UnicodeScalar(charIndex)!)
                txt = "\(txt)\(char) "
            }
            txt.removeLast()
            return txt
        }
    }
    
    @objc func buttonPressed(button: UIButton) {
        switch button.tag {
        case 10:    // touchID / faceID
            let context = LAContext()
            var error: NSError?

            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                let reason = WStrings.Wallet_Biometric_Reason.localized

                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) {
                    [weak self] success, authenticationError in

                    DispatchQueue.main.async { [weak self] in
                        if success {
                            self?.onAuth()
                        } else {
                        }
                    }
                }
            } else {
                showAlert(title: WStrings.Wallet_Biometric_NotAvailableTitle.localized,
                          text: WStrings.Wallet_Biometric_NotAvailableText.localized,
                          button: WStrings.Wallet_Alert_OK.localized)
            }
            break
        case 11:    // 0 number
            passcodeInputView.currentPasscode += "0"
            break
        case 12:
            passcodeInputView.deleteBackward()
        default:
            passcodeInputView.currentPasscode += "\(button.tag)"
        }
    }

}

extension UnlockVC: PasscodeInputViewDelegate {
    func passcodeChanged(passcode: String) {
    }
    
    func passcodeSelected(passcode: String) {
        if passcode == KeychainHelper.passcode() {
            dismiss(animated: true) { [weak self] in
                self?.onAuth()
            }
        } else {
            passcodeInputView.currentPasscode = ""
            // TODO::
        }
    }
}
