//
//  RecentAddressCell.swift
//  UIWalletSend
//
//  Created by Sina on 5/18/23.
//

import UIKit
import UIComponents
import WalletContext
import WalletCore

class RecentAddressCell: UITableViewCell {
    
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
        primaryLabel = UILabel()
        primaryLabel.translatesAutoresizingMaskIntoConstraints = false
        primaryLabel.font = .systemFont(ofSize: 16)
        addSubview(primaryLabel)
        NSLayoutConstraint.activate([
            primaryLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            primaryLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 16),
            primaryLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -16)
        ])

        secondaryLabel = UILabel()
        secondaryLabel.translatesAutoresizingMaskIntoConstraints = false
        secondaryLabel.font = .systemFont(ofSize: 14)
        addSubview(secondaryLabel)
        NSLayoutConstraint.activate([
            secondaryLabel.topAnchor.constraint(equalTo: primaryLabel.bottomAnchor, constant: 2),
            secondaryLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 16),
            secondaryLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -16)
        ])

        // seaparator
        let separatorView = UIView()
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        separatorView.backgroundColor = WTheme.separator
        addSubview(separatorView)
        NSLayoutConstraint.activate([
            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor),
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            separatorView.heightAnchor.constraint(equalToConstant: 0.33)
        ])

        updateTheme()
    }
    
    func updateTheme() {
        primaryLabel.textColor = WTheme.primaryLabel
        secondaryLabel.textColor = WTheme.secondaryLabel
    }
    
    public func configure(with recentAddress: RecentAddress) {
        if let addressAlias = recentAddress.addressAlias {
            // addresses that have alias (`raw address` or `dns address`) are shown with their alias
            primaryLabel.text = addressAlias
            secondaryLabel.text = formatStartEndAddress(recentAddress.address)
        } else {
            // show address and submittion date, for addresses with no alias
            primaryLabel.text = formatStartEndAddress(recentAddress.address)
            let addressDate = Date(timeIntervalSinceReferenceDate: TimeInterval(recentAddress.timstamp))
            let sameYear = Date().isInSameYear(as: addressDate)
            let dateFormatter = DateFormatter()
            if sameYear {
                dateFormatter.timeStyle = .medium
            } else {
                dateFormatter.dateFormat = "MMMM d"
            }
            secondaryLabel.text = dateFormatter.string(from: addressDate)
        }
    }
    
}
