//
//  WTextInput.swift
//  UIComponents
//
//  Created by Sina on 4/23/23.
//

import UIKit
import WalletContext

public protocol WAddressInputDelegate: AnyObject {
    func addressTextChanged()
}

public class WAddressInput: UITextView {
    
    private weak var addressDelegate: WAddressInputDelegate?
    public init(delegate: WAddressInputDelegate) {
        self.addressDelegate = delegate
        super.init(frame: .zero, textContainer: nil)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public var placeholderLabel: UILabel!
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    public override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setup()
    }
    
    private var heightConstraint: NSLayoutConstraint!
    
    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        heightConstraint = heightAnchor.constraint(equalToConstant: 50)
        NSLayoutConstraint.activate([
            heightConstraint,
        ])

        delegate = self

        layer.cornerRadius = 10
        font = .systemFont(ofSize: 17, weight: .regular)
        
        // setup placeholder
        placeholderLabel = UILabel()
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        placeholderLabel.font = font
        addSubview(placeholderLabel)
        NSLayoutConstraint.activate([
            placeholderLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            placeholderLabel.topAnchor.constraint(equalTo: topAnchor, constant: 14),
            placeholderLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            placeholderLabel.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: 14),
        ])
        
        textContainerInset = UIEdgeInsets(top: 14, left: 12, bottom: 14, right: 12)

        // set theme colors
        updateTheme()
    }
    
    func updateTheme() {
        backgroundColor = currentTheme.groupedBackground
        placeholderLabel.textColor = currentTheme.secondaryLabel
    }

}

extension WAddressInput: UITextViewDelegate {
    public func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty

        heightConstraint.constant = max(50, textView.contentSize.height)
        layoutIfNeeded()

        addressDelegate?.addressTextChanged()
    }
}
