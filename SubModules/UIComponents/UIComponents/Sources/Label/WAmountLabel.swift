//
//  WAmountLabel.swift
//  UIComponents
//
//  Created by Sina on 4/20/23.
//

import UIKit
import WalletContext

public class WAmountLabel: UILabel {
    
    private static let defaultNumberFont = UIFont.systemFont(ofSize: 19, weight: .medium)
    private static let defaultDecimalsFont = UIFont.systemFont(ofSize: 15, weight: .regular)
    
    public var amount: Int64 = 0 {
        didSet {
            updateTheme()
        }
    }

    private let numberFont: UIFont
    private let decimalsFont: UIFont
    public init(numberFont: UIFont? = nil, decimalsFont: UIFont? = nil) {
        self.numberFont = numberFont ?? WAmountLabel.defaultNumberFont
        self.decimalsFont = decimalsFont ?? WAmountLabel.defaultDecimalsFont
        super.init(frame: CGRect.zero)
        updateTheme()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    public override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setup()
    }
    
    private func setup() {
        // set theme colors
        updateTheme()
    }
    
    func updateTheme() {
        // reset text color
        let components = formatBalanceText(amount).components(separatedBy: ".")
        let attr = NSMutableAttributedString(string: "\(components[0])", attributes: [
            NSAttributedString.Key.font: numberFont,
            NSAttributedString.Key.foregroundColor: amount > 0 ? currentTheme.positiveAmount : currentTheme.negativeAmount
        ])
        if components.count > 1 {
            attr.append(NSAttributedString(string: ".\(components[1])", attributes: [
                NSAttributedString.Key.font: decimalsFont,
                NSAttributedString.Key.foregroundColor: amount > 0 ? currentTheme.positiveAmount : currentTheme.negativeAmount
            ]))
        }
        attributedText = attr
    }
}
