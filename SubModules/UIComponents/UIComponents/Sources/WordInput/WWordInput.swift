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

public class WWordInput: UIView {
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
        translatesAutoresizingMaskIntoConstraints = false

        // corner radius
        layer.cornerRadius = 10

        // We had to wrap UIStackView inside a UIView to be able to set backgroundColor on WWordInput on older iOS versions;
        //  Because, prior to iOS 14, stack views were "non-rendering" views
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 6
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leftAnchor.constraint(equalTo: leftAnchor),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.rightAnchor.constraint(equalTo: rightAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.heightAnchor.constraint(equalToConstant: 50)
        ])

        // add word number label
        numberLabel.translatesAutoresizingMaskIntoConstraints = false
        numberLabel.text = "\(wordNumber):"
        numberLabel.textAlignment = .right
        stackView.addArrangedSubview(numberLabel)
        NSLayoutConstraint.activate([
            numberLabel.widthAnchor.constraint(equalToConstant: 42)
        ])
        
        // add text field
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.backgroundColor = .clear
        textField.delegate = self
        stackView.addArrangedSubview(textField)
        
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
