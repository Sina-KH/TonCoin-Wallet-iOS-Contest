//
//  BalanceView.swift
//  UIWalletHome
//
//  Created by Sina on 4/21/23.
//

import UIKit
import UIComponents
import WalletContext

public class BalanceView: UIStackView {

    public init() {
        super.init(frame: CGRect.zero)
        setupView()
    }

    override public init(frame: CGRect) {
        fatalError()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var balanceLabel: UILabel!

    public var balance: Int64 = -1 {
        didSet {
            if balance == -1 {
                if balanceLabel.superview != nil {
                    balanceLabel.removeFromSuperview()
                }
            } else {
                if balanceLabel.superview == nil {
                    addArrangedSubview(balanceLabel)
                }
            }
            // TODO:: Balance label component required
            let components = formatBalanceText(balance).components(separatedBy: ".")
            let attr = NSMutableAttributedString(string: "\(components[0])", attributes: [
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 48, weight: .semibold),
                NSAttributedString.Key.foregroundColor: currentTheme.balanceHeaderView.balance
            ])
            if components.count > 1 {
                attr.append(NSAttributedString(string: ".\(components[1])", attributes: [
                    NSAttributedString.Key.font: UIFont.systemFont(ofSize: 30, weight: .semibold),
                    NSAttributedString.Key.foregroundColor: currentTheme.balanceHeaderView.balance
                ]))
            }
            balanceLabel.attributedText = attr
        }
    }

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        spacing = 8
        alignment = .center
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 56)
        ])

        // add animated gem
        let animatedSticker = WAnimatedSticker()
        animatedSticker.animationName = "Main"
        animatedSticker.translatesAutoresizingMaskIntoConstraints = false
        animatedSticker.setup(width: 44,
                              height: 44,
                              playbackMode: .once)
        addArrangedSubview(animatedSticker)
        NSLayoutConstraint.activate([
            animatedSticker.widthAnchor.constraint(equalToConstant: CGFloat(44)),
            animatedSticker.heightAnchor.constraint(equalToConstant: CGFloat(44))
        ])

        balanceLabel = UILabel()
        balanceLabel.textColor = currentTheme.balanceHeaderView.balance
        balanceLabel.translatesAutoresizingMaskIntoConstraints = false
        addArrangedSubview(balanceLabel)
    }

}
