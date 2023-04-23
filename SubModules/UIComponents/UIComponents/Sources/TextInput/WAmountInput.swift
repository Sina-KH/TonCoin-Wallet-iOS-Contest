//
//  WAmountInput.swift
//  UIComponents
//
//  Created by Sina on 4/23/23.
//

import UIKit
import WalletContext

public class WAmountInput: UITextField {
    
    public init() {
        super.init(frame: .zero)
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
        
        font = .systemFont(ofSize: 48, weight: .semibold)
        placeholder = "0"
        
        leftViewMode = .always
        leftView = UIImageView(image: UIImage(named: "SendGem")!)
        
        // set theme colors
        updateTheme()
    }
    
    func updateTheme() {
    }

    public override func textRect(forBounds bounds: CGRect) -> CGRect {
        return CGRectInset(bounds , 44, 0)
    }

    // text position
    public override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return CGRectInset(bounds , 44, 0)
    }
}
