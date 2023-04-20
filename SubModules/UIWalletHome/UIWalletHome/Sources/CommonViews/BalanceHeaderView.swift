//
//  BalanceHeaderView.swift
//  UIWalletHome
//
//  Created by Sina on 4/20/23.
//

import UIKit
import UIComponents
import WalletContext

public class BalanceHeaderView: UIView {
    
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
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 300)
        ])
        backgroundColor = currentTheme.balanceHeaderView.background

        // bottom corner radius
        let bottomCornersView = UIView()
        bottomCornersView.translatesAutoresizingMaskIntoConstraints = false
        bottomCornersView.backgroundColor = currentTheme.background
        bottomCornersView.layer.cornerRadius = 16
        addSubview(bottomCornersView)
        NSLayoutConstraint.activate([
            bottomCornersView.leftAnchor.constraint(equalTo: leftAnchor, constant: 0),
            bottomCornersView.rightAnchor.constraint(equalTo: rightAnchor, constant: 0),
            bottomCornersView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 16),
            bottomCornersView.heightAnchor.constraint(equalToConstant: 32)
        ])

        // send/receive actions
        let actionsStackView = UIStackView()
        actionsStackView.translatesAutoresizingMaskIntoConstraints = false
        actionsStackView.spacing = 12
        actionsStackView.distribution = .fillEqually
        addSubview(actionsStackView)
        NSLayoutConstraint.activate([
            actionsStackView.leftAnchor.constraint(equalTo: leftAnchor, constant: 16),
            actionsStackView.rightAnchor.constraint(equalTo: rightAnchor, constant: -16),
            actionsStackView.bottomAnchor.constraint(equalTo: bottomCornersView.topAnchor, constant: -16)
        ])

        let receiveButton = WButton.setupInstance(.accent)
        receiveButton.translatesAutoresizingMaskIntoConstraints = false
        receiveButton.setTitle(WStrings.Wallet_Home_Receive.localized, for: .normal)
        actionsStackView.addArrangedSubview(receiveButton)

        let sendButton = WButton.setupInstance(.accent)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.setTitle(WStrings.Wallet_Home_Send.localized, for: .normal)
        actionsStackView.addArrangedSubview(sendButton)

    }
    
}
