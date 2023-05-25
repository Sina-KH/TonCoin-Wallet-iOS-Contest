//
//  BalanceView.swift
//  UIWalletHome
//
//  Created by Sina on 4/21/23.
//

import UIKit
import WalletContext

public class BalanceView: UIView {

    private var textColor: UIColor? = nil
    public init(textColor: UIColor?) {
        self.textColor = textColor
        super.init(frame: CGRect.zero)
        setupView()
    }

    override public init(frame: CGRect) {
        fatalError()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var animatedSticker: WAnimatedSticker!
    private var balanceLabel: WAnimatedBalanceLabel!
    // height of the view
    private var heightConstraint: NSLayoutConstraint!
    // width of aniamted sticker, it's used to make animated sticker frame smaller when transforming it
    private var animatedStickerWidthConstraint: NSLayoutConstraint!
    // space between animation and the balance
    private var spacingConstraint: NSLayoutConstraint!
    // scale of the view
    private var scale: CGFloat? = nil

    // -2: not loaded, -1: empty
    public var balance: Int64 = -2 {
        didSet {
            if balance == -2 {
                balanceLabel.amount = nil
                spacingConstraint.constant = 0
            } else {
                balanceLabel.amount = max(0, balance) // -1 is empty wallet
                spacingConstraint.constant = 8
            }
        }
    }

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        heightConstraint = heightAnchor.constraint(equalToConstant: 56)
        NSLayoutConstraint.activate([
            heightConstraint
        ])

        // add animated gem
        animatedSticker = WAnimatedSticker()
        animatedSticker.animationName = "Main"
        animatedSticker.translatesAutoresizingMaskIntoConstraints = false
        animatedSticker.setup(width: 44,
                              height: 44,
                              playbackMode: .once)
        addSubview(animatedSticker)
        animatedStickerWidthConstraint = animatedSticker.widthAnchor.constraint(equalToConstant: CGFloat(44))
        NSLayoutConstraint.activate([
            animatedSticker.leftAnchor.constraint(equalTo: leftAnchor),
            animatedStickerWidthConstraint,
            animatedSticker.heightAnchor.constraint(equalToConstant: 44),
            animatedSticker.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])

        balanceLabel = WAnimatedBalanceLabel()
        balanceLabel.textColor = textColor ?? WTheme.primaryLabel
        addSubview(balanceLabel)
        spacingConstraint = balanceLabel.leftAnchor.constraint(equalTo: animatedSticker.rightAnchor, constant: 8)
        NSLayoutConstraint.activate([
            spacingConstraint,
            balanceLabel.rightAnchor.constraint(equalTo: rightAnchor),
            balanceLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])

        update(scale: 1)
    }

    /// Update scale of the balance view.
    ///
    /// - Parameters:
    ///     - scale: A number between 0.5 (collapsed) and 1 (expanded).
    public func update(scale: CGFloat) {
        if self.scale == scale {
            return
        }
        self.scale = scale
        let transformScale = 0.36 + 1.28 * (scale - 0.5)
        animatedSticker.transform = CGAffineTransform(scaleX: transformScale,
                                                      y: transformScale)
        animatedStickerWidthConstraint.constant = 16 + 56 * (scale - 0.5)
        heightConstraint.constant = 22 + 112 * (scale - 0.5)
        updateBalanceLabelFont()
    }
    
    private func updateBalanceLabelFont() {
        balanceLabel.numberLabel.font = .systemFont(ofSize: 17 + 62 * ((scale ?? 1) - 0.5), weight: .semibold)
        balanceLabel.decimalsLabel.font = .systemFont(ofSize: 17 + 26 * ((scale ?? 1) - 0.5), weight: .semibold)
        balanceLabel.updateWidth()
    }
}
