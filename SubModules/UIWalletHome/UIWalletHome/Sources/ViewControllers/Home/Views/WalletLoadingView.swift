//
//  WalletLoadingView.swift
//  UIWalletHome
//
//  Created by Sina on 4/21/23.
//

import UIKit
import UIComponents
import WalletContext

public class WalletLoadingView: UIView {
    
    public init() {
        super.init(frame: CGRect.zero)
        setupView()
    }
    
    override public init(frame: CGRect) {
        fatalError()
    }
    
    required public init?(coder: NSCoder) {
        fatalError()
    }
    
    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        isUserInteractionEnabled = false
        
        // add animated sticker
        let animatedSticker = WAnimatedSticker()
        animatedSticker.animationName = "Loading"
        animatedSticker.translatesAutoresizingMaskIntoConstraints = false
        animatedSticker.setup(width: 124,
                              height: 124,
                              playbackMode: .loop)
        addSubview(animatedSticker)
        NSLayoutConstraint.activate([
            animatedSticker.topAnchor.constraint(equalTo: topAnchor),
            animatedSticker.centerXAnchor.constraint(equalTo: centerXAnchor),
            animatedSticker.widthAnchor.constraint(equalToConstant: CGFloat(124)),
            animatedSticker.heightAnchor.constraint(equalToConstant: CGFloat(124)),
            animatedSticker.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
}
