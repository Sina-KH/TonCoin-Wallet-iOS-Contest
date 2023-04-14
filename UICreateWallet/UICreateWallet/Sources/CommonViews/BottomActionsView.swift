//
//  BottomActionsView.swift
//  UICreateWallet
//
//  Created by Sina on 4/14/23.
//

import UIKit
import UIComponents

struct BottomAction {
    var title: String
    var onPress: () -> ()
}

class BottomActionsView: UIView {

    init(primaryAction: BottomAction, secondaryAction: BottomAction? = nil) {
        super.init(frame: CGRect.zero)
        setupView(primaryAction: primaryAction, secondaryAction: secondaryAction)
    }
    
    override init(frame: CGRect) {
        fatalError()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private var primaryAction: BottomAction? = nil
    private var secondaryAction: BottomAction? = nil

    private func setupView(primaryAction: BottomAction,
                           secondaryAction: BottomAction? = nil) {
        self.primaryAction = primaryAction
        self.secondaryAction = secondaryAction
        
        translatesAutoresizingMaskIntoConstraints = false
        
        // add primary action
        let primaryButton = WButtonPrimary(type: .system)
        primaryButton.translatesAutoresizingMaskIntoConstraints = false
        primaryButton.setup()
        primaryButton.setTitle(primaryAction.title, for: .normal)
        primaryButton.addTarget(self, action: #selector(primaryPressed(_:)), for: .touchUpInside)
        addSubview(primaryButton)
        NSLayoutConstraint.activate([
            primaryButton.topAnchor.constraint(equalTo: topAnchor),
            primaryButton.leftAnchor.constraint(equalTo: leftAnchor),
            primaryButton.rightAnchor.constraint(equalTo: rightAnchor),
        ])

        // secondary button
        if let secondaryAction {
            let secondaryButton = WButtonSecondary(type: .system)
            secondaryButton.translatesAutoresizingMaskIntoConstraints = false
            secondaryButton.setup()
            secondaryButton.setTitle(secondaryAction.title, for: .normal)
            secondaryButton.addTarget(self, action: #selector(secondaryPressed(_:)), for: .touchUpInside)
            addSubview(secondaryButton)
            NSLayoutConstraint.activate([
             secondaryButton.topAnchor.constraint(equalTo: primaryButton.bottomAnchor, constant: 16),
             secondaryButton.leftAnchor.constraint(equalTo: leftAnchor),
             secondaryButton.rightAnchor.constraint(equalTo: rightAnchor),
             secondaryButton.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
        } else {
            primaryButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -66).isActive = true
        }
    }
    
    @objc func primaryPressed(_ sender: UIButton) {
        primaryAction?.onPress()
    }

    @objc func secondaryPressed(_ sender: UIButton) {
        secondaryAction?.onPress()
    }
}
