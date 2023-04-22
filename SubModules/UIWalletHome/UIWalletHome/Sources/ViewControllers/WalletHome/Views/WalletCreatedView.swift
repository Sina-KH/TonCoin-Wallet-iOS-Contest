//
//  WalletCreatedView.swift
//  UIWalletHome
//
//  Created by Sina on 4/21/23.
//

import UIKit
import UIComponents
import WalletContext

public class WalletCreatedView: UIView {

    public init(address: String) {
        super.init(frame: CGRect.zero)
        setupView(address: address)
    }

    override public init(frame: CGRect) {
        fatalError()
    }
    
    required public init?(coder: NSCoder) {
        fatalError()
    }

    var titleLabel: UILabel!

    private func setupView(address: String) {
        translatesAutoresizingMaskIntoConstraints = false

        let headerView = HeaderView(animationName: "Created",
                                    animationPlaybackMode: .once,
                                    title: WStrings.Wallet_Home_WalletCreated.localized,
                                    description: nil)
        addSubview(headerView)
        NSLayoutConstraint.activate([
            headerView.leftAnchor.constraint(equalTo: leftAnchor, constant: 32),
            headerView.rightAnchor.constraint(equalTo: rightAnchor, constant: -32),
            headerView.topAnchor.constraint(equalTo: topAnchor)
        ])
        
        titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        titleLabel.text = WStrings.Wallet_Home_Address.localized
        titleLabel.textAlignment = .center
        addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: isIPhone5s ? 4 : 28),
            titleLabel.leftAnchor.constraint(equalTo: leftAnchor),
            titleLabel.rightAnchor.constraint(equalTo: rightAnchor)
        ])

        let addressLabel = UILabel()
        addressLabel.translatesAutoresizingMaskIntoConstraints = false
        addressLabel.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        addressLabel.numberOfLines = 2
        addressLabel.text = formatAddress(address)
        addressLabel.textAlignment = .center
        addSubview(addressLabel)
        NSLayoutConstraint.activate([
            addressLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: isIPhone5s ? 6 : 2),
            addressLabel.leftAnchor.constraint(equalTo: leftAnchor),
            addressLabel.rightAnchor.constraint(equalTo: rightAnchor),
            addressLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        updateTheme()
    }

    func updateTheme() {
        titleLabel.textColor = currentTheme.secondaryLabel
    }

    // pass touch events to below view
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        if hitView == self {
            return nil
        } else {
            return hitView
        }
    }
}
