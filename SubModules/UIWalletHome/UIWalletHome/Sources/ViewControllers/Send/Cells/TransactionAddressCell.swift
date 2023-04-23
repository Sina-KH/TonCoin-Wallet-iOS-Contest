//
//  TransactionAddressCell.swift
//  UIWalletHome
//
//  Created by Sina on 4/23/23.
//

import UIKit
import UIComponents
import WalletContext
import WalletCore

class TransactionAddressCell: UITableViewCell {
    
    private static let regular16Font = UIFont.systemFont(ofSize: 16, weight: .regular)
    private static let regular14Font = UIFont.systemFont(ofSize: 14, weight: .regular)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private var primaryLabel: UILabel!
    private var secondaryLabel: UILabel!

    private func setupViews() {
        // setup cell as a vertical stack view
        let verticalStackView = UIStackView()
        verticalStackView.translatesAutoresizingMaskIntoConstraints = false
        verticalStackView.axis = .vertical
        verticalStackView.alignment = .leading
        verticalStackView.spacing = 2
        addSubview(verticalStackView)
        NSLayoutConstraint.activate([
            verticalStackView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            verticalStackView.leftAnchor.constraint(equalTo: leftAnchor, constant: 16),
            verticalStackView.rightAnchor.constraint(equalTo: rightAnchor, constant: -16),
            verticalStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
        ])

        // primary label
        primaryLabel = UILabel()
        primaryLabel.translatesAutoresizingMaskIntoConstraints = false
        primaryLabel.font = TransactionAddressCell.regular16Font
        verticalStackView.addArrangedSubview(primaryLabel)
        
        // secondary label
        secondaryLabel = UILabel()
        secondaryLabel.translatesAutoresizingMaskIntoConstraints = false
        secondaryLabel.font = TransactionAddressCell.regular14Font
        verticalStackView.addArrangedSubview(secondaryLabel)

        updateTheme()
    }
    
    func updateTheme() {
        secondaryLabel.textColor = currentTheme.secondaryLabel
    }
    
    public func configure() {
        // TODO::
    }
    
}
