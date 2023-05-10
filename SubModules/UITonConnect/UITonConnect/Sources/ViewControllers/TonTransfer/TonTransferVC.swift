//
//  TonTransferVC.swift
//  UITonConnect
//
//  Created by Sina on 5/10/23.
//

import UIKit
import UIComponents
import WalletContext
import WalletCore

public class TonTransferVC: WViewController {

    private let walletInfo: WalletInfo
    private let addressToSend: String

    private lazy var tonTransferViewModel = TonTransferVM(tonTransferVMDelegate: self)
    
    public init(walletInfo: WalletInfo, addressToSend: String) {
        self.walletInfo = walletInfo
        self.addressToSend = addressToSend
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Load and SetupView Functions
    public override func loadView() {
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
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            stackView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 0),
            stackView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: 0),
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8)
        ])
        
        // navigation bar
        let doneItem = WNavigationBarButton(text: WStrings.Wallet_Navigation_Done.localized,
                                            onPress: { [weak self] in
            self?.dismiss(animated: true)
        })
        let navigationBar = WNavigationBar(title: WStrings.Wallet_TonConnectTransfer_Title.localized,
                                           trailingItem: doneItem)
        stackView.addArrangedSubview(navigationBar)
        NSLayoutConstraint.activate([
            navigationBar.leftAnchor.constraint(equalTo: stackView.leftAnchor, constant: 0),
            navigationBar.rightAnchor.constraint(equalTo: stackView.rightAnchor, constant: 0)
        ])

        // gap
        stackView.setCustomSpacing(20, after: navigationBar)

        let amountView = BalanceView(textColor: nil)
        amountView.balance = 2000000000
        stackView.addArrangedSubview(amountView)

        stackView.setCustomSpacing(36, after: amountView)

        let fullWidthStackView = UIStackView()
        fullWidthStackView.axis = .vertical
        fullWidthStackView.alignment = .fill
        stackView.addArrangedSubview(fullWidthStackView)
        NSLayoutConstraint.activate([
            fullWidthStackView.leftAnchor.constraint(equalTo: stackView.leftAnchor),
            fullWidthStackView.rightAnchor.constraint(equalTo: stackView.rightAnchor)
        ])
        fullWidthStackView.addArrangedSubview(TitleValueRowView(title: WStrings.Wallet_TonConnectTransfer_Recipient.localized,
                                                                value: formatStartEndAddress(addressToSend)))
        fullWidthStackView.addArrangedSubview(TitleValueRowView(title: WStrings.Wallet_SendConfirm_Amount.localized,
                                                                value: "≈ 0.004 TON"))
        
        stackView.setCustomSpacing(80, after: fullWidthStackView)
        
        // send/receive actions
        let actionsStackView = UIStackView()
        actionsStackView.translatesAutoresizingMaskIntoConstraints = false
        actionsStackView.spacing = 12
        actionsStackView.distribution = .fillEqually
        stackView.addArrangedSubview(actionsStackView)
        NSLayoutConstraint.activate([
            actionsStackView.leftAnchor.constraint(equalTo: stackView.leftAnchor, constant: 16),
            actionsStackView.rightAnchor.constraint(equalTo: stackView.rightAnchor, constant: -16)
        ])

        let cancelButton = WButton.setupInstance(.accentLight)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.setTitle(WStrings.Wallet_TonConnectTransfer_Cancel.localized, for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelPressed), for: .touchUpInside)
        actionsStackView.addArrangedSubview(cancelButton)

        let confirmButton = WButton.setupInstance(.primary)
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        confirmButton.setTitle(WStrings.Wallet_TonConnectTransfer_Confirm.localized, for: .normal)
        confirmButton.addTarget(self, action: #selector(sendPressed), for: .touchUpInside)
        actionsStackView.addArrangedSubview(confirmButton)
    }

    @objc func donePressed() {
        dismiss(animated: true)
    }
    
    @objc func cancelPressed() {
        dismiss(animated: true)
    }
    
    @objc func sendPressed() {
        // TODO::
    }
}

extension TonTransferVC: TonTransferVMDelegate {
    
}
