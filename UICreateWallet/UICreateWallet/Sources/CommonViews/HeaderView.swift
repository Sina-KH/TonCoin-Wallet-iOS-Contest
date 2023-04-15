//
//  HeaderView.swift
//  UICreateWallet
//
//  Created by Sina on 4/14/23.
//

import UIKit
import UIComponents

class HeaderView: UIView {

    init(animationName: String,
         animationWidth: Int,
         animationHeight: Int,
         animationReply: Bool,
         title: String,
         description: String) {
        super.init(frame: CGRect.zero)
        setupView(animationName: animationName,
                  animationWidth: animationWidth,
                  animationHeight: animationHeight,
                  animationReply: animationReply,
                  title: title,
                  description: description)
    }
    
    override init(frame: CGRect) {
        fatalError()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func setupView(animationName: String,
                           animationWidth: Int,
                           animationHeight: Int,
                           animationReply: Bool,
                           title: String,
                           description: String) {
        translatesAutoresizingMaskIntoConstraints = false
        
        // add animated sticker
        let animatedSticker = WAnimatedSticker()
        animatedSticker.animationName = animationName
        animatedSticker.replay = animationReply
        animatedSticker.translatesAutoresizingMaskIntoConstraints = false
        animatedSticker.setup(width: animationWidth,
                              height: animationHeight)
        addSubview(animatedSticker)
        NSLayoutConstraint.activate([
            animatedSticker.topAnchor.constraint(equalTo: topAnchor),
            animatedSticker.centerXAnchor.constraint(equalTo: centerXAnchor),
            animatedSticker.widthAnchor.constraint(equalToConstant: CGFloat(animationWidth)),
            animatedSticker.heightAnchor.constraint(equalToConstant: CGFloat(animationHeight))
        ])
        
        // title
        let lblTitle = UILabel()
        lblTitle.translatesAutoresizingMaskIntoConstraints = false
        lblTitle.text = title
        lblTitle.font = UIFont.systemFont(ofSize: 28, weight: .semibold)
        lblTitle.numberOfLines = 0
        lblTitle.textAlignment = .center
        addSubview(lblTitle)
        NSLayoutConstraint.activate([
            lblTitle.topAnchor.constraint(equalTo: animatedSticker.bottomAnchor, constant: 12),
            lblTitle.leftAnchor.constraint(equalTo: leftAnchor),
            lblTitle.rightAnchor.constraint(equalTo: rightAnchor)
        ])

        // description
        let lblDescription = UILabel()
        lblDescription.translatesAutoresizingMaskIntoConstraints = false
        lblDescription.text = description
        lblDescription.font = UIFont.systemFont(ofSize: 17)
        lblDescription.numberOfLines = 0
        lblDescription.textAlignment = .center
        addSubview(lblDescription)
        NSLayoutConstraint.activate([
            lblDescription.topAnchor.constraint(equalTo: lblTitle.bottomAnchor, constant: 12),
            lblDescription.leftAnchor.constraint(equalTo: leftAnchor),
            lblDescription.rightAnchor.constraint(equalTo: rightAnchor),
            lblDescription.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

    }
    
}