//
//  PasscodeInputView.swift
//  UIPasscode
//
//  Created by Sina on 4/16/23.
//

import UIKit
import WalletContext

protocol PasscodeInputViewDelegate: AnyObject {
    func passcodeChanged(passcode: String)
    func passcodeSelected(passcode: String)
}

class PasscodeInputView: UIStackView {
    
    // MARK: Make view present keyboard
    var _inputView: UIView?
    
    override var canBecomeFirstResponder: Bool { return true }
    override var canResignFirstResponder: Bool { return true }
    
    override var inputView: UIView? {
        set { _inputView = newValue }
        get { return _inputView }
    }

    // MARK: Init and setup view
    weak var delegate: PasscodeInputViewDelegate?
    let theme: WThemePasscodeInput

    var circles = [UIView]()
    var currentPasscode = String() {
        didSet {
            textUpdated()
        }
    }
    static let defaultPasscodeLength = 4
    var maxPasscodeLength = 6
    var passcodeLength = PasscodeInputView.defaultPasscodeLength

    init(delegate: PasscodeInputViewDelegate?, theme: WThemePasscodeInput = WTheme.setPasscodeInput) {
        self.delegate = delegate
        self.theme = theme
        super.init(frame: CGRect.zero)
        setupView()
    }
    
    override init(frame: CGRect) {
        fatalError()
    }
    
    required init(coder: NSCoder) {
        fatalError()
    }
    
    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false

        // spacing between inputs
        spacing = 16

        // create circles
        for i in 0 ..< maxPasscodeLength {
            let circle = UIView()
            circle.translatesAutoresizingMaskIntoConstraints = false
            circle.layer.cornerRadius = 8
            circle.layer.borderColor = theme.border.cgColor
            circle.layer.borderWidth = 1
            NSLayoutConstraint.activate([
                circle.widthAnchor.constraint(equalToConstant: 16),
                circle.heightAnchor.constraint(equalToConstant: 16)
            ])
            circles.append(circle)
            if i < passcodeLength {
                addArrangedSubview(circle)
            }
        }
    }

    func setCirclesCount(to num: Int) {
        if passcodeLength == num {
            return
        }
        currentPasscode = ""
        if num < 1 || num > maxPasscodeLength {
            return
        }
        for i in 0 ..< num {
            if circles[i].superview == nil {
                addArrangedSubview(circles[i])
            }
        }
        for i in num ..< maxPasscodeLength {
            if circles[i].superview != nil {
                circles[i].removeFromSuperview()
            }
        }
    }
    
    func textUpdated() {
        delegate?.passcodeChanged(passcode: currentPasscode)

        // update circle colors
        let textLength = currentPasscode.count
        for i in 0 ..< maxPasscodeLength {
            circles[i].backgroundColor = i < textLength ? theme.fill : theme.empty
        }
        if currentPasscode.count == passcodeLength {
            delegate?.passcodeSelected(passcode: currentPasscode)
        }
    }

}

// MARK: - UIKeyInput
extension PasscodeInputView: UIKeyInput {
    var hasText: Bool { return true }
    func insertText(_ text: String) {
        guard let num = Int(text.normalizeArabicPersianNumeralStringToWestern()) else {
            return
        }
        if currentPasscode.count < passcodeLength {
            currentPasscode += "\(num)"
        }
    }
    func deleteBackward() {
        currentPasscode = String(currentPasscode.dropLast(1))
    }
    var keyboardType: UIKeyboardType {
        get {
            return .numberPad
        }
        set {}
    }
}
