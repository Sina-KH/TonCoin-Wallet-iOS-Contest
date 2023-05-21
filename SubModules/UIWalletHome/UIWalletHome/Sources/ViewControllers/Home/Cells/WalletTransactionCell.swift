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
    private static let monoSpacedRegular15Font = UIFont.monospacedSystemFont(ofSize: 15, weight: .regular)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private let dateFormatter = DateFormatter()
    private var verticalStackView = UIStackView()
    private var dateLabel: UILabel!
    private var amountLabel: WAmountLabel!
    private var directionLabel: UILabel!
    private var addressLabel: UILabel!
    private var timeLabel: UILabel!
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

        // date label
        dateLabel = UILabel()
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        verticalStackView.addArrangedSubview(dateLabel)
        verticalStackView.setCustomSpacing(14, after: dateLabel)

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
        timeLabel = UILabel()
        timeLabel.font = WalletTransactionCell.regular15Font
        topLineStackView.addArrangedSubview(timeLabel)
        verticalStackView.addArrangedSubview(topLineStackView)
        NSLayoutConstraint.activate([
            topLineStackView.widthAnchor.constraint(equalTo: verticalStackView.widthAnchor)
        ])

        // address
        addressLabel = UILabel()
        addressLabel.translatesAutoresizingMaskIntoConstraints = false
        addressLabel.font = WalletTransactionCell.monoSpacedRegular15Font
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
        storageFeeLabel.textColor = WTheme.secondaryLabel
    }
    
    public func configure(with transactionItem: HomeListTransaction, prevItem: HomeListTransaction?) {
        let itemDate: Date

        switch transactionItem {
        case .completed(let transaction):
            
            itemDate = Date(timeIntervalSince1970: TimeInterval(transaction.timestamp))

            // set amount
            amountLabel.amount = transaction.transferredValueWithoutFees

            // prepare address and description texts
            let (addressString, descriptionString, _) = transaction.extractAddressAndDescription()
            var isEmpty = false

            // direction label string
            if transaction.transferredValueWithoutFees <= 0 {
                // sent
                if transaction.outMessages.isEmpty {
                    directionLabel.text =
                        transaction.isInitialization ? WStrings.Wallet_Home_InitTransaction.localized : WStrings.Wallet_Home_UnknownTransaction.localized
                    isEmpty = true
                } else {
                    directionLabel.text = WStrings.Wallet_Home_TransactionTo.localized
                }
            } else {
                directionLabel.text = WStrings.Wallet_Home_TransactionFrom.localized
            }

            // datetime
            timeLabel.text = stringForTimestamp(timestamp: Int32(clamping: transaction.timestamp))
            timeLabel.textColor = WTheme.secondaryLabel
            
            if isEmpty {
                // hide labels on empty/unknown transaction
                storageFeeLabel.isHidden = true
                addressLabel.isHidden = true
                bubbleView.isHidden = true
                amountLabel.text = nil
            } else {
                storageFeeLabel.isHidden = false
                addressLabel.isHidden = false
                addressLabel.text = addressString
                
                // storage fee label
                storageFeeLabel.text = WStrings.Wallet_Home_TransactionStorageFee(storageFee: formatBalanceText(transaction.storageFee))
                
                // show comment (description string) in a bubble view
                if descriptionString.count == 0 {
                    bubbleView.isHidden = true
                } else {
                    bubbleView.isHidden = false
                    bubbleView.text = descriptionString
                }
            }

        case .pending(let transaction):

            itemDate = Date(timeIntervalSince1970: TimeInterval(transaction.timestamp))

            // set amount
            amountLabel.amount = -transaction.value

            // prepare address and description texts
            let (addressString, descriptionString, _) = transaction.extractAddressAndDescription()

            // direction label string
            directionLabel.text = WStrings.Wallet_Home_TransactionTo.localized

            addressLabel.text = addressString

            // datetime
            // can use stringForTimestamp(timestamp: Int32(clamping: transaction.timestamp))
            timeLabel.text = WStrings.Wallet_Home_TransactionPending.localized
            timeLabel.textColor = WTheme.primaryButton.background
            
            // storage fee label
            storageFeeLabel.text = nil

            // show comment (description string) in a bubble view
            if descriptionString.count == 0 {
                bubbleView.isHidden = true
            } else {
                bubbleView.text = descriptionString
                bubbleView.isHidden = false
            }

            // should show all labels
            storageFeeLabel.isHidden = false
            addressLabel.isHidden = false

            break
        }

        // extract prev item date to compare with current item's date and time
        var prevItemDate: Date? = nil
        if let prevItem {
            switch prevItem {
            case .completed(let transaction):
                prevItemDate = Date(timeIntervalSince1970: TimeInterval(transaction.timestamp))
                break
            case .pending(let transaction):
                prevItemDate = Date(timeIntervalSince1970: TimeInterval(transaction.timestamp))
                break
            }
        }

        // show top section date if it's a new day
        if !(prevItemDate?.isInSameDay(as: itemDate) ?? false) {
            dateLabel.isHidden = false
            let sameYear = Date().isInSameYear(as: itemDate)
            if sameYear {
                dateFormatter.dateFormat = "MMMM d"
            } else {
                dateFormatter.timeStyle = .medium
            }
            dateLabel.text = dateFormatter.string(from: itemDate)
            dateLabel.isHidden = false
        } else {
            dateLabel.isHidden = true
        }
    }
    
}
