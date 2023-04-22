//
//  SendVC.swift
//  UIWalletHome
//
//  Created by Sina on 4/22/23.
//

import UIKit
import UIComponents
import WalletContext
import WalletCore

class SendVC: WViewController {
    
    // MARK: - Initializer
    let walletContext: WalletContext
    let walletInfo: WalletInfo
    public init(walletContext: WalletContext, walletInfo: WalletInfo) {
        self.walletContext = walletContext
        self.walletInfo = walletInfo
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

    private var addressHintLabel: UILabel!
    private var recentsLabel: UILabel!

    func setupViews() {
        navigationItem.title = WStrings.Wallet_Send_Title.localized
        // add done button if it's root of a navigation controller
        if navigationController?.viewControllers.count == 1 {
            let cancelButton = UIBarButtonItem(title: WStrings.Wallet_Navigation_Cancel.localized, style: .done, target: self, action: #selector(cancelPressed))
            navigationItem.rightBarButtonItem = cancelButton
        }

        // container stack view
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .fill
        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            stackView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            stackView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12)
        ])

        // top stack view with left and right margins
        let topStackView = UIStackView()
        topStackView.translatesAutoresizingMaskIntoConstraints = false
        topStackView.axis = .vertical
        topStackView.spacing = 16
        topStackView.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        topStackView.isLayoutMarginsRelativeArrangement = true
        stackView.addArrangedSubview(topStackView)

        // top address field
        let addressField = UITextView()
        addressField.translatesAutoresizingMaskIntoConstraints = false
        addressField.backgroundColor = currentTheme.groupedBackground
        addressField.layer.cornerRadius = 10
        addressField.font = .systemFont(ofSize: 17, weight: .regular)
        let addressFieldHeightConstraint = addressField.heightAnchor.constraint(equalToConstant: 50)
        addressFieldHeightConstraint.priority = UILayoutPriority(999)
        NSLayoutConstraint.activate([
            addressFieldHeightConstraint,
            addressField.heightAnchor.constraint(greaterThanOrEqualToConstant: 50)
        ])
        topStackView.addArrangedSubview(addressField)
        
        // address hint
        addressHintLabel = UILabel()
        addressHintLabel.translatesAutoresizingMaskIntoConstraints = false
        addressHintLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        addressHintLabel.numberOfLines = 0
        addressHintLabel.text = WStrings.Wallet_Send_AddressInfo.localized
        topStackView.addArrangedSubview(addressHintLabel)
        
        // paste/scan stack view
        let addressActionsStackView = UIStackView()
        addressActionsStackView.translatesAutoresizingMaskIntoConstraints = false
        topStackView.addArrangedSubview(addressActionsStackView)
        addressActionsStackView.spacing = 20
        let pasteButton = WButton.setupInstance(.secondary)
        pasteButton.setTitle(WStrings.Wallet_Send_Paste.localized, for: .normal)
        pasteButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        pasteButton.setImage(UIImage(named: "PasteIcon"), for: .normal)
        pasteButton.centerTextAndImage(spacing: 6)
        addressActionsStackView.addArrangedSubview(pasteButton)
        let scanButton = WButton.setupInstance(.secondary)
        scanButton.setTitle(WStrings.Wallet_Send_Scan.localized, for: .normal)
        scanButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        addressActionsStackView.addArrangedSubview(scanButton)
        addressActionsStackView.addArrangedSubview(UIView())

        // recents top bar
        let recentsTopStackView = UIStackView()
        recentsTopStackView.translatesAutoresizingMaskIntoConstraints = false
        recentsTopStackView.layoutMargins = UIEdgeInsets(top: 24, left: 0, bottom: 0, right: 0)
        recentsTopStackView.isLayoutMarginsRelativeArrangement = true
        NSLayoutConstraint.activate([
            recentsTopStackView.heightAnchor.constraint(equalToConstant: 18)
        ])
        topStackView.addArrangedSubview(recentsTopStackView)
        
        // recents label
        recentsLabel = UILabel()
        recentsLabel.translatesAutoresizingMaskIntoConstraints = false
        recentsLabel.text = WStrings.Wallet_Send_Recents.localized
        recentsLabel.font = .systemFont(ofSize: 13, weight: .regular)
        recentsTopStackView.addArrangedSubview(recentsLabel)

        // recents clear button
        let clearRecentsButton = WButton.setupInstance(.secondary)
        clearRecentsButton.translatesAutoresizingMaskIntoConstraints = false
        clearRecentsButton.setTitle(WStrings.Wallet_Send_Clear.localized, for: .normal)
        clearRecentsButton.titleLabel?.font = .systemFont(ofSize: 13, weight: .regular)
        recentsTopStackView.addArrangedSubview(clearRecentsButton)

        // recents table view
        stackView.addArrangedSubview(UIView())

        // continue button
        let bottomStackView = UIStackView()
        bottomStackView.translatesAutoresizingMaskIntoConstraints = false
        bottomStackView.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        bottomStackView.isLayoutMarginsRelativeArrangement = true
        stackView.addArrangedSubview(bottomStackView)
        let continueButton = WButton.setupInstance(.primary)
        continueButton.translatesAutoresizingMaskIntoConstraints = false
        continueButton.setTitle(WStrings.Wallet_Send_Continue.localized, for: .normal)
        bottomStackView.addArrangedSubview(continueButton)

        updateTheme()
    }
    
    func updateTheme() {
        addressHintLabel.textColor = currentTheme.secondaryLabel
    }
    
    @objc func cancelPressed() {
        dismiss(animated: true)
    }
}
