//
//  PasscodeInputView.swift
//  UIPasscode
//
//  Created by Sina on 4/16/23.
//

import UIKit
import WalletContext

protocol PasscodeInputViewDelegate: AnyObject {
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

    var circles = [UIView]()
    var currentPasscode = String()
    var maxPasscodeLength = 6
    var passcodeLength = 6

    init(delegate: PasscodeInputViewDelegate) {
        self.delegate = delegate
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
        for _ in 0 ..< maxPasscodeLength {
            let circle = UIView()
            circle.translatesAutoresizingMaskIntoConstraints = false
            circle.layer.cornerRadius = 8
            circle.layer.borderColor = currentTheme.border.cgColor
            circle.layer.borderWidth = 1
            circles.append(circle)
            addArrangedSubview(circle)
            NSLayoutConstraint.activate([
                circle.widthAnchor.constraint(equalToConstant: 16),
                circle.heightAnchor.constraint(equalToConstant: 16)
            ])
        }
    }

    func setCirclesCount(to num: Int) {
        if num < 1 || num > maxPasscodeLength {
            return
        }
        for i in 0 ..< num {
            if circles[i].superview == nil {
                addArrangedSubview(circles[i])
            }
        }
        for i in num - 1 ..< maxPasscodeLength {
            if circles[i].superview != nil {
                circles[i].removeFromSuperview()
            }
        }
    }
    
    func textUpdated() {
        // update circle colors
        let textLength = currentPasscode.count
        for i in 0 ..< maxPasscodeLength {
            circles[i].backgroundColor = i < textLength ? currentTheme.backgroundReverse : currentTheme.background
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
        if currentPasscode.count < passcodeLength {
            currentPasscode += text
            textUpdated()
        }
    }
    func deleteBackward() {
        currentPasscode = String(currentPasscode.dropLast(1))
        textUpdated()
    }
    var keyboardType: UIKeyboardType {
        get {
            return .numberPad
        }
        set {}
    }
}