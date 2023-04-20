//
//  WalletTransactionCell.swift
//  UIWalletHome
//
//  Created by Sina on 4/20/23.
//

import UIKit
import UIComponents

class WalletTransactionCell: UITableViewCell {
    
    static let balanceGem = UIImage(named: "BalanceGem")!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        let verticalStackView = UIStackView()
        verticalStackView.axis = .vertical
        verticalStackView.spacing = 6

        // icon and amount stack view
        let iconAndAmountStackView = UIStackView()
        iconAndAmountStackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(iconAndAmountStackView)
        NSLayoutConstraint.activate([
            iconAndAmountStackView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            iconAndAmountStackView.leftAnchor.constraint(equalTo: leftAnchor, constant: 16)
        ])
        // icon
        let iconImageView = UIImageView()
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            iconImageView.widthAnchor.constraint(equalToConstant: 18),
            iconImageView.heightAnchor.constraint(equalToConstant: 18)
        ])
        iconAndAmountStackView.addSubview(iconImageView)
        iconImageView.image = WalletTransactionCell.balanceGem
        // amount
        let amountLabel = WAmountLabel()
        amountLabel.translatesAutoresizingMaskIntoConstraints = false
        iconAndAmountStackView.addSubview(amountLabel)
    }
    
    public func configure() {
        
    }
    
}
