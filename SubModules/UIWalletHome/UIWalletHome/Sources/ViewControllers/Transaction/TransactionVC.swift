//
//  TransactionVC.swift
//  UIWalletHome
//
//  Created by Sina on 4/22/23.
//

import UIKit
import UIWalletSend
import UIComponents
import WalletContext
import WalletCore
import SwiftSignalKit

class TransactionVC: WViewController {
    
    private let walletContext: WalletContext
    private let walletInfo: WalletInfo
    private let transaction: HomeListTransaction
    private weak var homeVC: WalletHomeVC?
    init(walletContext: WalletContext,
         walletInfo: WalletInfo,
         transaction: HomeListTransaction,
         homeVC: WalletHomeVC?) {
        self.walletContext = walletContext
        self.walletInfo = walletInfo
        self.transaction = transaction
        self.homeVC = homeVC
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var transactionFeeLabel: UILabel!
    private var dateTimeLabel: UILabel!
    private var detailsLabel: UILabel!
    private var addressItem: TitleValueRowView!
    private var transactionIDItem: TitleValueRowView!
    private var viewInExplorerButton: UIButton!
    
    override func loadView() {
        super.loadView()
        setupViews()
    }
    
    private func setupViews() {
        var constraints = [NSLayoutConstraint]()

        let stackView = UIStackView()
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 16, right: 0)
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center
        view.addSubview(stackView)
        constraints.append(contentsOf: [
            stackView.topAnchor.constraint(equalTo: view.topAnchor),
            stackView.leftAnchor.constraint(equalTo: view.leftAnchor),
            stackView.rightAnchor.constraint(equalTo: view.rightAnchor),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        // navigation bar
        let doneItem = WNavigationBarButton(text: WStrings.Wallet_Navigation_Done.localized,
                                            onPress: { [weak self] in
            self?.dismiss(animated: true)
        })
        let navigationBar = WNavigationBar(title: WStrings.Wallet_TransactionInfo_Title.localized,
                                           trailingItem: doneItem)
        stackView.addArrangedSubview(navigationBar)
        constraints.append(contentsOf: [
            navigationBar.leftAnchor.constraint(equalTo: stackView.leftAnchor, constant: 0),
            navigationBar.rightAnchor.constraint(equalTo: stackView.rightAnchor, constant: 0)
        ])

        // gap
        stackView.setCustomSpacing(20, after: navigationBar)
        
        // icon and amount stack view
        let iconAndAmountStackView = UIStackView()
        iconAndAmountStackView.translatesAutoresizingMaskIntoConstraints = false
        constraints.append(
            iconAndAmountStackView.heightAnchor.constraint(equalToConstant: 56)
        )
        iconAndAmountStackView.spacing = 8
        iconAndAmountStackView.alignment = .center
        // icon
        let iconImageView = UIImageView()
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        constraints.append(contentsOf: [
            iconImageView.widthAnchor.constraint(equalToConstant: 36),
            iconImageView.heightAnchor.constraint(equalToConstant: 36)
        ])
        iconAndAmountStackView.addArrangedSubview(iconImageView)
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.image = UIImage(named: "SendGem")!
        // amount
        let amountLabel = WAmountLabel(numberFont: UIFont.systemFont(ofSize: 48, weight: .semibold),
                                       decimalsFont: UIFont.systemFont(ofSize: 30, weight: .semibold))
        amountLabel.translatesAutoresizingMaskIntoConstraints = false
        iconAndAmountStackView.addArrangedSubview(amountLabel)
        
        stackView.addArrangedSubview(iconAndAmountStackView)
        
        // gap
        stackView.setCustomSpacing(6, after: iconAndAmountStackView)

        // other fee label
        transactionFeeLabel = UILabel()
        transactionFeeLabel.font = .systemFont(ofSize: 15, weight: .regular)
        stackView.addArrangedSubview(transactionFeeLabel)
        
        // gap
        stackView.setCustomSpacing(4, after: transactionFeeLabel)
        
        // date time label
        // TODO:: Pending/Canceled transactions don't have date time!
        dateTimeLabel = UILabel()
        dateTimeLabel.font = .systemFont(ofSize: 15, weight: .regular)
        stackView.addArrangedSubview(dateTimeLabel)

        // data from transaction
        let (addressString, descriptionString, _): (String, String, Bool)
        let addressTitle: String
        let hashPreview: String

        // Fill fields and init variables required based on transaction type
        switch transaction {
        case .completed(let trn):
            (addressString, descriptionString, _) = trn.extractAddressAndDescription()
            amountLabel.amount = trn.transferredValueWithoutFees
            transactionFeeLabel.text = WStrings.Wallet_TransactionInfo_OtherFee(otherFee: formatBalanceText(trn.otherFee))
            dateTimeLabel.text = trn.timestamp.dateTimeString
            addressTitle = trn.transferredValueWithoutFees > 0 ?
                WStrings.Wallet_TransactionInfo_SenderAddress.localized :
                WStrings.Wallet_TransactionInfo_RecipientAddress.localized
            hashPreview = trn.hashPreview
            break
        case .pending(let trn):
            (addressString, descriptionString, _) = trn.extractAddressAndDescription()
            amountLabel.amount = -trn.value
            // TODO:: Fee should be added to the logic
            transactionFeeLabel.text = nil
            dateTimeLabel.text = WStrings.Wallet_TransactionInfo_Pending.localized
            addressTitle = WStrings.Wallet_TransactionInfo_RecipientAddress.localized
            hashPreview = trn.hashPreview
            break
        }
        //

        // comment bubble view
        if descriptionString.count > 0 {
            // gap
            stackView.setCustomSpacing(16, after: dateTimeLabel)
            let bubbleView = BubbleView()
            bubbleView.text = descriptionString
            stackView.addArrangedSubview(bubbleView)
            // gap
            stackView.setCustomSpacing(38, after: bubbleView)
        } else {
            // gap
            stackView.setCustomSpacing(38, after: dateTimeLabel)
        }
        
        // details label
        detailsLabel = UILabel()
        detailsLabel.translatesAutoresizingMaskIntoConstraints = false
        detailsLabel.font = .systemFont(ofSize: 13, weight: .regular)
        detailsLabel.text = WStrings.Wallet_TransactionInfo_Details.localized
        stackView.addArrangedSubview(detailsLabel)
        constraints.append(
            detailsLabel.leftAnchor.constraint(equalTo: stackView.leftAnchor, constant: 16)
        )
        
        // TODO:: Recipient DNS (?!)

        // sender/recipient
        addressItem = TitleValueRowView(title: addressTitle, value: formatStartEndAddress(addressString))
        stackView.addArrangedSubview(addressItem)
        constraints.append(contentsOf: [
            addressItem.leftAnchor.constraint(equalTo: stackView.leftAnchor),
            addressItem.rightAnchor.constraint(equalTo: stackView.rightAnchor)
        ])
        
        // transaction
        transactionIDItem = TitleValueRowView(title: WStrings.Wallet_TransactionInfo_Transaction.localized,
                                              value: hashPreview)
        stackView.addArrangedSubview(transactionIDItem)
        constraints.append(contentsOf: [
            transactionIDItem.leftAnchor.constraint(equalTo: stackView.leftAnchor),
            transactionIDItem.rightAnchor.constraint(equalTo: stackView.rightAnchor)
        ])

        // view in explorer
        let viewInExplorerRow = UIStackView()
        viewInExplorerRow.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 24, right: 16)
        viewInExplorerRow.isLayoutMarginsRelativeArrangement = true
        viewInExplorerRow.axis = .vertical
        viewInExplorerRow.alignment = .leading
        stackView.addArrangedSubview(viewInExplorerRow)
        constraints.append(contentsOf: [
            viewInExplorerRow.leftAnchor.constraint(equalTo: stackView.leftAnchor)
        ])
        viewInExplorerButton = UIButton(type: .system)
        viewInExplorerButton.translatesAutoresizingMaskIntoConstraints = false
        constraints.append(
            viewInExplorerButton.heightAnchor.constraint(equalToConstant: 44)
        )
        viewInExplorerButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        viewInExplorerButton.setTitle(WStrings.Wallet_TransactionInfo_ViewInExplorer.localized, for: .normal)
        viewInExplorerButton.addTarget(self, action: #selector(viewInExplorerPressed), for: .touchUpInside)
        viewInExplorerButton.translatesAutoresizingMaskIntoConstraints = false
        viewInExplorerRow.addArrangedSubview(viewInExplorerButton)

        // bottom button
        let bottomButton = WButton.setupInstance(.primary)
        // TODO:: Retry button if transaction is canceled (?)
        switch transaction {
        case .completed(let walletTransaction):
            if walletTransaction.extractAddress() == nil {
                // hide bottom button for unknown transactions
                bottomButton.isHidden = true
                // indicate that it's an unknown transaction instead of address title
                addressItem.setValueText(WStrings.Wallet_Home_UnknownTransaction.localized)
            }
        case .pending:
            break
        }
        bottomButton.setTitle(WStrings.Wallet_TransactionInfo_SendTONToThisAddress.localized, for: .normal)
        bottomButton.addTarget(self, action: #selector(bottomButtonPressed), for: .touchUpInside)
        stackView.addArrangedSubview(bottomButton)
        constraints.append(
            bottomButton.leftAnchor.constraint(equalTo: stackView.leftAnchor, constant: 16)
        )

        NSLayoutConstraint.activate(constraints)

        updateTheme()
    }
    
    func updateTheme() {
        transactionFeeLabel.textColor = WTheme.secondaryLabel
        switch transaction {
        case .completed(_):
            dateTimeLabel.textColor = WTheme.secondaryLabel
            break
        case .pending(_):
            dateTimeLabel.textColor = WTheme.primaryButton.background
            break
        }
        detailsLabel.textColor = WTheme.secondaryLabel
        addressItem.setValueTextColor(WTheme.secondaryLabel)
        transactionIDItem.setValueTextColor(WTheme.secondaryLabel)
    }
    
    @objc private func viewInExplorerPressed() {
        let hash: String
        switch transaction {
        case .completed(let walletTransaction):
            hash = walletTransaction.transactionId.transactionHash.base64EncodedString()
        case .pending(let pendingWalletTransaction):
            hash = pendingWalletTransaction.bodyHash.base64EncodedString()
        }
        // get wallet configuration info
        let _ = (walletContext.storage.localWalletConfiguration()
                 |> take(1)
                 |> deliverOnMainQueue).start(next: { configuration in
            
            let baseURL = configuration.testNet.customId == "mainnet" ? "https://tonscan.org/tx/" : "https://testnet.tonscan.org/tx/"
            if let url = URL(string: "\(baseURL)\(hash)") {
                UIApplication.shared.open(url)
            }
            
        })
    }
    
    @objc private func bottomButtonPressed() {
        let addressString: String
        switch transaction {
        case .completed(let walletTransaction):
            addressString = walletTransaction.extractAddress() ?? ""
        case .pending(let pendingWalletTransaction):
            addressString = pendingWalletTransaction.address
        }
        RecentAddressesHelpers.saveRecentAddress(recentAddress: RecentAddress(address: addressString,
                                                                              addressAlias: nil,
                                                                              timstamp: Date().timeIntervalSince1970), walletVersion: walletInfo.version)
        let sendVC = SendVC(walletContext: walletContext,
                            walletInfo: walletInfo,
                            balance: nil,
                            defaultAddress: addressString)
        let sendAmountVC = SendAmountVC(walletContext: walletContext,
                                        walletInfo: walletInfo,
                                        addressToSend: addressString,
                                        balance: homeVC?.walletHomeVM.combinedState?.walletState.effectiveAvailableBalance)
        let nav = UINavigationController()
        nav.viewControllers = [sendVC, sendAmountVC]
        present(nav, animated: true)
    }
}
