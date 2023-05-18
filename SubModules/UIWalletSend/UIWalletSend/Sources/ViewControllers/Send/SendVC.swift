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
import UIQRScan
import WalletUrl
import SwiftSignalKit

public class SendVC: WViewController {
    
    // MARK: - Initializer
    private let walletContext: WalletContext
    private let walletInfo: WalletInfo
    private let balance: Int64?
    private let defaultAddress: String?
    public init(walletContext: WalletContext, walletInfo: WalletInfo, balance: Int64?, defaultAddress: String? = nil) {
        self.walletContext = walletContext
        self.walletInfo = walletInfo
        self.balance = balance
        self.defaultAddress = defaultAddress
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

    private var stackViewBottomConstraint: NSLayoutConstraint!
    private var addressField: WAddressInput!
    private var addressHintLabel: UILabel!
    private var recentsLabel: UILabel!
    private var continueButton: WButton!
    private var recentsTopStackView: UIStackView!

    func setupViews() {
        navigationItem.title = WStrings.Wallet_Send_Title.localized
        // add done button if it's root of a navigation controller
        if navigationController?.viewControllers.count == 1 {
            let cancelButton = UIBarButtonItem(title: WStrings.Wallet_Navigation_Cancel.localized, style: .plain, target: self, action: #selector(cancelPressed))
            navigationItem.leftBarButtonItem = cancelButton
        }
        navigationItem.backBarButtonItem = UIBarButtonItem(
            title: WStrings.Wallet_Navigation_Back.localized, style: .plain, target: nil, action: nil
        )

        // container stack view
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .fill
        view.addSubview(stackView)
        stackViewBottomConstraint = stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            stackView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            stackView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            stackViewBottomConstraint
        ])

        // top stack view with left and right margins (we don't want recents table view to have margins)
        let topStackView = UIStackView()
        topStackView.translatesAutoresizingMaskIntoConstraints = false
        topStackView.axis = .vertical
        topStackView.spacing = 16
        topStackView.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        topStackView.isLayoutMarginsRelativeArrangement = true
        stackView.addArrangedSubview(topStackView)

        // top address field
        addressField = WAddressInput(delegate: self)
        addressField.placeholderLabel.text = WStrings.Wallet_Send_AddressText.localized
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
        pasteButton.translatesAutoresizingMaskIntoConstraints = false
        pasteButton.setTitle(WStrings.Wallet_Send_Paste.localized, for: .normal)
        pasteButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        pasteButton.setImage(UIImage(named: "SendPasteIcon"), for: .normal)
        pasteButton.centerTextAndImage(spacing: 6)
        pasteButton.addTarget(self, action: #selector(pastePressed), for: .touchUpInside)
        addressActionsStackView.addArrangedSubview(pasteButton)
        let scanButton = WButton.setupInstance(.secondary)
        scanButton.translatesAutoresizingMaskIntoConstraints = false
        scanButton.setTitle(WStrings.Wallet_Send_Scan.localized, for: .normal)
        scanButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        scanButton.setImage(UIImage(named: "SendScanIcon"), for: .normal)
        scanButton.centerTextAndImage(spacing: 6)
        scanButton.addTarget(self, action: #selector(scanPressed), for: .touchUpInside)
        addressActionsStackView.addArrangedSubview(scanButton)
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        addressActionsStackView.addArrangedSubview(v)

        // recents top bar
        recentsTopStackView = UIStackView()
        recentsTopStackView.isHidden = true
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
        continueButton = WButton.setupInstance(.primary)
        continueButton.translatesAutoresizingMaskIntoConstraints = false
        continueButton.isEnabled = false
        continueButton.setTitle(WStrings.Wallet_Send_Continue.localized, for: .normal)
        continueButton.addTarget(self, action: #selector(continuePressed), for: .touchUpInside)
        bottomStackView.addArrangedSubview(continueButton)

        // listen for keyboard
        WKeyboardObserver.observeKeyboard(delegate: self)

        updateTheme()

        #if DEBUG
        addressField.text = "EQAbrFKnUptp9c5qP5aqtvnuh5ZqzHezqcsithIXHxd4O2ha"
        addressField.textViewDidChange(self.addressField)
        #endif
        if let defaultAddress {
            addressField.text = defaultAddress
            addressField.textViewDidChange(self.addressField)
        }
    }
    
    func updateTheme() {
        addressHintLabel.textColor = WTheme.secondaryLabel
    }

    func showWrongAddressToast() {
        ToastView.presentAbove(continueButton,
                               icon: UIImage(named: "Warning")!,
                               title: WStrings.Wallet_Send_ErrorInvalidAddressTitle.localized,
                               text: WStrings.Wallet_Send_ErrorInvalidAddressText.localized)
    }

    var isLoading: Bool = false {
        didSet {
            continueButton.showLoading = isLoading
            view.isUserInteractionEnabled = !isLoading
        }
    }

    // MARK: - Actions
    @objc func cancelPressed() {
        dismiss(animated: true)
    }
    
    @objc func pastePressed() {
        let pb: UIPasteboard = UIPasteboard.general
        addressField.text = pb.string
    }
    
    @objc func scanPressed() {
        navigationController?.pushViewController(QRScanVC(walletContext: walletContext,
                                                          walletInfo: walletInfo,
                                                          callback: { [weak self] url in
            guard let self else {
                return
            }
            if let parsedURL = parseWalletUrl(url) {
                addressField.text = parsedURL.address
                addressField.textViewDidChange(addressField)
            }
        }), animated: true)
    }
    
    @objc func continuePressed() {
        isLoading = true
        let address = addressField.text ?? ""
        ContextAddressHelpers.toBase64Address(unknownAddress: address,
                                              walletContext: walletContext) { [weak self] base64Address in
            guard let self else {
                return
            }
            isLoading = false
            guard let base64Address else {
                showWrongAddressToast()
                return
            }
            navigateToSendVC(address: base64Address, addressAlias: base64Address != address ? address : nil)
        }
    }
    
    func navigateToSendVC(address: String, addressAlias: String?) {
        navigationController?.pushViewController(SendAmountVC(walletContext: walletContext,
                                                              walletInfo: walletInfo,
                                                              addressToSend: address,
                                                              balance: balance,
                                                              addressAlias: addressAlias),
                                                 animated: true)
    }
}

extension SendVC: WKeyboardObserverDelegate {
    public func keyboardWillShow(height: CGFloat) {
        UIView.animate(withDuration: 0.25) {
            self.stackViewBottomConstraint.constant = -height - 12 + self.view.safeAreaInsets.bottom
            self.view.layoutIfNeeded()
        }
    }
    
    public func keyboardWillHide() {
        UIView.animate(withDuration: 0.25) {
            self.stackViewBottomConstraint.constant = -12
            self.view.layoutIfNeeded()
        }
    }
}

extension SendVC: WAddressInputDelegate {
    public func addressTextChanged() {
        continueButton.isEnabled = !addressField.text.isEmpty
    }
}
