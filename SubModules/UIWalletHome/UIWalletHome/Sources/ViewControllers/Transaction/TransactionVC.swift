//
//  TransactionVC.swift
//  UIWalletHome
//
//  Created by Sina on 4/22/23.
//

import UIKit
import UIComponents
import WalletContext
import WalletCore

class TransactionVC: WViewController {
    
    private let transaction: WalletTransaction
    init(transaction: WalletTransaction) {
        self.transaction = transaction
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        setupViews()
    }
    
    private func setupViews() {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center
        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.topAnchor),
            stackView.leftAnchor.constraint(equalTo: view.leftAnchor),
            stackView.rightAnchor.constraint(equalTo: view.rightAnchor),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor)
        ])
        
        // navigation bar
        let navigationBar = WNavigationBar(title: WStrings.Wallet_TransactionInfo_Title.localized)
        stackView.addArrangedSubview(navigationBar)
        
        // icon and amount stack view
        let iconAndAmountStackView = UIStackView()
        iconAndAmountStackView.translatesAutoresizingMaskIntoConstraints = false
        iconAndAmountStackView.spacing = 4
        iconAndAmountStackView.alignment = .center
        // icon
        let iconImageView = UIImageView()
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
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
        amountLabel.amount = transaction.transferredValueWithoutFees
        iconAndAmountStackView.addArrangedSubview(amountLabel)
        
        stackView.addArrangedSubview(iconAndAmountStackView)
    }
}
