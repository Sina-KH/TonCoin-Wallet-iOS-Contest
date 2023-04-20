//
//  WAmountLabel.swift
//  UIComponents
//
//  Created by Sina on 4/20/23.
//

import UIKit

public class WAmountLabel: UILabel {
    
    private static let numberFont = UIFont.systemFont(ofSize: 19, weight: .medium)
    private static let decimalsFont = UIFont.systemFont(ofSize: 15, weight: .regular)
    
    var amount: Double = 0 {
        didSet {
            let components = "\(abs(amount))".components(separatedBy: ".")
            let attr = NSMutableAttributedString(string: "\(components[0])", attributes: [
                NSAttributedString.Key.font: WAmountLabel.numberFont
            ])
            if components.count > 0 {
                attr.append(NSAttributedString(string: ".\(components[1])", attributes: [
                    NSAttributedString.Key.font: WAmountLabel.decimalsFont
                ]))
            }
        }
    }

    public init() {
        super.init(frame: CGRect.zero)
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
        
    }
}
