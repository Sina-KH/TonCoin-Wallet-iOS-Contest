//
//  WalletTransactionCell.swift
//  UIWalletHome
//
//  Created by Sina on 4/20/23.
//

import UIKit
import UIComponents
import WalletContext
import WalletCore

class WalletTransactionCell: UITableViewCell {
    
    private static let balanceGem = UIImage(named: "BalanceGem")!
    private static let regular15Font = UIFont.systemFont(ofSize: 15, weight: .regular)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private var verticalStackView = UIStackView()
    private var amountLabel: WAmountLabel!
    private var directionLabel: UILabel!
    private var addressLabel: UILabel!
    private var dateLabel: UILabel!
    private var storageFeeLabel: UILabel!
    private var bubbleView: BubbleView!

    private func setupViews() {
        // setup whole cell as a vertical stack view
        verticalStackView = UIStackView()
        verticalStackView.translatesAutoresizingMaskIntoConstraints = false
        verticalStackView.axis = .vertical
        verticalStackView.alignment = .leading
        verticalStackView.spacing = 6
        addSubview(verticalStackView)
        NSLayoutConstraint.activate([
            verticalStackView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            verticalStackView.leftAnchor.constraint(equalTo: leftAnchor, constant: 16),
            verticalStackView.rightAnchor.constraint(equalTo: rightAnchor, constant: -16),
            verticalStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])

        // icon and amount stack view
        let iconAndAmountStackView = UIStackView()
        iconAndAmountStackView.translatesAutoresizingMaskIntoConstraints = false
        iconAndAmountStackView.spacing = 4
        // icon
        let iconImageView = UIImageView()
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            iconImageView.widthAnchor.constraint(equalToConstant: 18),
            iconImageView.heightAnchor.constraint(equalToConstant: 18)
        ])
        iconAndAmountStackView.addArrangedSubview(iconImageView)
        iconImageView.image = WalletTransactionCell.balanceGem
        // amount
        amountLabel = WAmountLabel()
        amountLabel.translatesAutoresizingMaskIntoConstraints = false
        iconAndAmountStackView.addArrangedSubview(amountLabel)
        // direction (from/to string)
        directionLabel = UILabel()
        directionLabel.translatesAutoresizingMaskIntoConstraints = false
        directionLabel.font = WalletTransactionCell.regular15Font
        iconAndAmountStackView.addArrangedSubview(directionLabel)

        // top line stack view including `icon and amount stack view` and `dateLabel`
        let topLineStackView = UIStackView()
        topLineStackView.distribution = .equalSpacing
        topLineStackView.addArrangedSubview(iconAndAmountStackView)
        dateLabel = UILabel()
        dateLabel.font = WalletTransactionCell.regular15Font
        topLineStackView.addArrangedSubview(dateLabel)
        verticalStackView.addArrangedSubview(topLineStackView)
        NSLayoutConstraint.activate([
            topLineStackView.widthAnchor.constraint(equalTo: verticalStackView.widthAnchor)
        ])

        // address
        addressLabel = UILabel()
        addressLabel.translatesAutoresizingMaskIntoConstraints = false
        addressLabel.font = WalletTransactionCell.regular15Font
        addressLabel.numberOfLines = 0
        verticalStackView.addArrangedSubview(addressLabel)
        
        // storage fee
        storageFeeLabel = UILabel()
        storageFeeLabel.translatesAutoresizingMaskIntoConstraints = false
        storageFeeLabel.font = WalletTransactionCell.regular15Font
        verticalStackView.addArrangedSubview(storageFeeLabel)

        // bubble comment view
        bubbleView = BubbleView()
        storageFeeLabel.translatesAutoresizingMaskIntoConstraints = false
        verticalStackView.addArrangedSubview(bubbleView)

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
        directionLabel.textColor = WTheme.secondaryLabel
        dateLabel.textColor = WTheme.secondaryLabel
        storageFeeLabel.textColor = WTheme.secondaryLabel
    }
    
    public func configure(with transactionItem: HomeListTransaction) {
        switch transactionItem {
        case .completed(let transaction):
            
            // set amount
            amountLabel.amount = transaction.transferredValueWithoutFees

            // prepare address and description texts
            let (addressString, descriptionString, _) = transaction.extractAddressAndDescription()

            // direction label string
            if transaction.transferredValueWithoutFees < 0 {
                // sent
                if transaction.outMessages.isEmpty {
                    directionLabel.text = ""
                } else {
                    directionLabel.text = WStrings.Wallet_Home_TransactionTo.localized
                }
            } else {
                directionLabel.text = WStrings.Wallet_Home_TransactionFrom.localized
            }

            addressLabel.text = addressString

            // datetime
            dateLabel.text = stringForTimestamp(timestamp: Int32(clamping: transaction.timestamp))
            
            // storage fee label
            storageFeeLabel.text = WStrings.Wallet_Home_TransactionStorageFee(storageFee: formatBalanceText(transaction.storageFee))

            // show comment (description string) in a bubble view
            if descriptionString.count == 0 {
                // remove from stackView to remove extra spacing
                if bubbleView.superview != nil {
                    bubbleView.removeFromSuperview()
                }
            } else {
                if bubbleView.superview == nil {
                    verticalStackView.addSubview(bubbleView)
                }
                bubbleView.text = descriptionString
            }

        case .pending(let transaction):
            
            // set amount
            amountLabel.amount = transaction.value

            // prepare address and description texts
            let (addressString, descriptionString, _) = transaction.extractAddressAndDescription()

            // direction label string
            directionLabel.text = WStrings.Wallet_Home_TransactionTo.localized

            addressLabel.text = addressString

            // datetime
            dateLabel.text = stringForTimestamp(timestamp: Int32(clamping: transaction.timestamp))
            
            // storage fee label
            storageFeeLabel.text = nil

            // show comment (description string) in a bubble view
            if descriptionString.count == 0 {
                // remove from stackView to remove extra spacing
                if bubbleView.superview != nil {
                    bubbleView.removeFromSuperview()
                }
            } else {
                if bubbleView.superview == nil {
                    verticalStackView.addSubview(bubbleView)
                }
                bubbleView.text = descriptionString
            }

            break
        }
    }
    
}
