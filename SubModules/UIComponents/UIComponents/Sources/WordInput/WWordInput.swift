//
//  WWordInput.swift
//  UIComponents
//
//  Created by Sina on 4/14/23.
//

import UIKit
import WalletContext

public class WWordInput: UIStackView {
    
    public var wordNumber: Int = 0

    let numberLabel = UILabel()
    public let textField = UITextField()

    public override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    public override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setup()
    }
    
    public func setup() {
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
        addArrangedSubview(textField)
        
        updateTheme()
    }

    func updateTheme() {
        backgroundColor = currentTheme.wordInput.background
        numberLabel.textColor = currentTheme.secondaryLabel
    }
}
