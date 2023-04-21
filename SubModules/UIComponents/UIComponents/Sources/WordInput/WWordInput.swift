//
//  WWordInput.swift
//  UIComponents
//
//  Created by Sina on 4/14/23.
//

import UIKit
import WalletContext

public protocol WWordInputDelegate: AnyObject {
    func resignedFirstResponder()
}

public class WWordInput: UIStackView {
    private var wordNumber: Int = 0
    private weak var delegate: WWordInputDelegate? = nil
    public init(wordNumber: Int, delegate: WWordInputDelegate) {
        self.wordNumber = wordNumber
        self.delegate = delegate
        super.init(frame: CGRect.zero)
        self.tag = wordNumber
        setup()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let numberLabel = UILabel()
    public let textField = UITextField()

    func setup() {
        axis = .horizontal
        spacing = 6

        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 50)
        ])

        // corner radius
        layer.cornerRadius = 10
        
        // add word number label
        numberLabel.translatesAutoresizingMaskIntoConstraints = false
        numberLabel.text = "\(wordNumber):"
        numberLabel.textAlignment = .right
        addArrangedSubview(numberLabel)
        NSLayoutConstraint.activate([
            numberLabel.widthAnchor.constraint(equalToConstant: 42)
        ])
        
        // add text field
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.backgroundColor = .clear
        textField.delegate = self
        addArrangedSubview(textField)
        
        updateTheme()
    }

    func updateTheme() {
        backgroundColor = currentTheme.wordInput.background
        numberLabel.textColor = currentTheme.secondaryLabel
    }
}

extension WWordInput: UITextFieldDelegate {
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextField = superview?.viewWithTag(tag + 1) as? WWordInput {
            nextField.textField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            delegate?.resignedFirstResponder()
        }
        return false
    }
}
