//
//  WAmountInput.swift
//  UIComponents
//
//  Created by Sina on 4/23/23.
//

import UIKit
import WalletContext

public protocol WAmountInputDelegate: AnyObject {
    func amountChanged()
}

public class WAmountInput: UITextView {
    
    private static let numberFont = UIFont.systemFont(ofSize: 48, weight: .semibold)
    private static let decimalsFont = UIFont.systemFont(ofSize: 30, weight: .semibold)

    private weak var amountDelegate: WAmountInputDelegate?
    public init(delegate: WAmountInputDelegate) {
        self.amountDelegate = delegate
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
    
    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 60),
            widthAnchor.constraint(greaterThanOrEqualToConstant: 83)
        ])
        isScrollEnabled = false

        delegate = self

        // setup left gem icon
        let sendGemImage = UIImage(named: "SendGem")!
        let imageView = UIImageView(image: sendGemImage)
        imageView.frame = CGRect(x: 0, y: (56 - sendGemImage.size.height) / 2,
                                 width: sendGemImage.size.width, height: sendGemImage.size.height)
        imageView.contentMode = UIView.ContentMode.center
        addSubview(imageView)

        // setup placeholder
        placeholderLabel = UILabel()
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        placeholderLabel.font = WAmountInput.numberFont
        placeholderLabel.text = "0"
        addSubview(placeholderLabel)
        NSLayoutConstraint.activate([
            placeholderLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: sendGemImage.size.width + 10),
            placeholderLabel.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            placeholderLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            placeholderLabel.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: 0),
        ])

        // set font to have big enough curse
        font = WAmountInput.numberFont
        textContainerInset = UIEdgeInsets(top: 0, left: sendGemImage.size.width + 6, bottom: 0, right: 0)

        // set theme colors
        updateTheme()
    }
    
    func updateTheme() {
        placeholderLabel.textColor = WTheme.secondaryLabel
    }

}

extension WAmountInput: UITextViewDelegate {
    public func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty

        let components = (text ?? "").components(separatedBy: ".")
        let attr = NSMutableAttributedString(string: "\(components[0])", attributes: [
            NSAttributedString.Key.font: WAmountInput.numberFont
        ])
        if components.count > 1 {
            attr.append(NSAttributedString(string: ".\(components[1])", attributes: [
                NSAttributedString.Key.font: WAmountInput.decimalsFont
            ]))
        }
        attributedText = attr
        
        amountDelegate?.amountChanged()
    }
}
