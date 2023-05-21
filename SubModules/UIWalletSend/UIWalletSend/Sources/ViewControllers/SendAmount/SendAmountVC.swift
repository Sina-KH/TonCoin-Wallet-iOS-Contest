//
//  SendAmountVC.swift
//  UIWalletHome
//
//  Created by Sina on 4/23/23.
//

import UIKit
import UIComponents
import WalletContext
import WalletCore

public class SendAmountVC: WViewController {
    
    // MARK: - Initializer
    private let walletContext: WalletContext
    private let walletInfo: WalletInfo
    private let addressToSend: String
    private var balance: Int64? {
        didSet {
            if let balance {
                allAmountLabel?.text = formatBalanceText(balance)
            }
        }
    }
    private let addressAlias: String?
    public init(walletContext: WalletContext,
                walletInfo: WalletInfo,
                addressToSend: String,
                balance: Int64? = nil,
                addressAlias: String? = nil) { // address alias can be `raw address` or the `dns address`
        self.walletContext = walletContext
        self.walletInfo = walletInfo
        self.addressToSend = addressToSend
        self.balance = balance
        self.addressAlias = addressAlias
        super.init(nibName: nil, bundle: nil)
        
        EventsHelper.observeBalanceUpdate(self, with: #selector(walletBalanceUpdated(notification:)))
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
    private var amountView: WAmountInput!
    private var insufficientFundsLabel: UILabel!
    private var sendAllStackView: UIStackView!
    private var allAmountLabel: UILabel?
    private var sendAllSwitch: UISwitch!
    private var continueButton: UIButton!

    func setupViews() {
        navigationItem.title = WStrings.Wallet_Send_Title.localized
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
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            stackView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16),
            stackView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -16),
            stackViewBottomConstraint
        ])

        // send to stack view
        let sendToStackView = UIStackView()
        stackView.addArrangedSubview(sendToStackView)
        let sendToLabel = UILabel()
        sendToStackView.spacing = 4
        sendToLabel.translatesAutoresizingMaskIntoConstraints = false
        let sendToAttributedString = NSMutableAttributedString(string: "\(WStrings.Wallet_SendAmount_SendTo.localized) ",
                                                               attributes: [
                                                                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17, weight: .regular),
                                                                NSAttributedString.Key.foregroundColor: WTheme.secondaryLabel
        ])
        sendToAttributedString.append(NSAttributedString(string: formatStartEndAddress(addressToSend),
                                                         attributes: [
                                                             NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17, weight: .regular),
                                                             NSAttributedString.Key.foregroundColor: WTheme.primaryLabel
        ]))
        if let addressAlias {
            // it's ton or raw address, if it's ton, we show the address itself.
            let showingAddressAlias =
                AddressHelpers.isTONDNSDomain(string: addressAlias) ? addressAlias : formatStartEndAddress(addressAlias, prefix: 6)
            sendToAttributedString.append(NSAttributedString(string: " \(showingAddressAlias)",
                                                             attributes: [
                                                                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17, weight: .regular),
                                                                NSAttributedString.Key.foregroundColor: WTheme.secondaryLabel
                                                             ]))
        }
        sendToLabel.setContentCompressionResistancePriority(UILayoutPriority.defaultLow, for: .horizontal)
        sendToLabel.attributedText = sendToAttributedString
        sendToStackView.addArrangedSubview(sendToLabel)
        let editButton = WButton.setupInstance(.secondary)
        editButton.translatesAutoresizingMaskIntoConstraints = false
        editButton.setTitle(WStrings.Wallet_SendAmount_Edit.localized, for: .normal)
        editButton.addTarget(self, action: #selector(editPressed), for: .touchUpInside)
        sendToStackView.addArrangedSubview(editButton)

        // amount
        let amountContainerView = UIView()
        amountContainerView.translatesAutoresizingMaskIntoConstraints = false
        amountContainerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(amountContainerPressed)))
        amountView = WAmountInput(delegate: self)
        amountView.translatesAutoresizingMaskIntoConstraints = false
        amountContainerView.addSubview(amountView)
        NSLayoutConstraint.activate([
            amountView.centerYAnchor.constraint(equalTo: amountContainerView.centerYAnchor),
            amountView.leftAnchor.constraint(greaterThanOrEqualTo: amountContainerView.leftAnchor, constant: 8),
            amountView.rightAnchor.constraint(lessThanOrEqualTo: amountContainerView.rightAnchor, constant: -8),
            amountView.centerXAnchor.constraint(equalTo: amountContainerView.centerXAnchor)
        ])
        // insufficient funds error
        insufficientFundsLabel = UILabel()
        insufficientFundsLabel.translatesAutoresizingMaskIntoConstraints = false
        insufficientFundsLabel.font = .systemFont(ofSize: 17, weight: .regular)
        insufficientFundsLabel.textColor = WTheme.error
        insufficientFundsLabel.text = WStrings.Wallet_SendAmount_NotEnoughFunds.localized
        insufficientFundsLabel.isHidden = true
        amountContainerView.addSubview(insufficientFundsLabel)
        NSLayoutConstraint.activate([
            insufficientFundsLabel.centerXAnchor.constraint(equalTo: amountContainerView.centerXAnchor),
            insufficientFundsLabel.topAnchor.constraint(equalTo: amountView.bottomAnchor, constant: 1)
        ])
        stackView.addArrangedSubview(amountContainerView)

        // send all
        sendAllStackView = UIStackView()
        sendAllStackView.translatesAutoresizingMaskIntoConstraints = false
        sendAllStackView.alignment = .center
        sendAllStackView.spacing = 4
        sendAllStackView.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 8, right: 0)
        sendAllStackView.isLayoutMarginsRelativeArrangement = true
        NSLayoutConstraint.activate([
            sendAllStackView.heightAnchor.constraint(equalToConstant: 52)
        ])
        stackView.addArrangedSubview(sendAllStackView)
        let sendAllLabel = UILabel()
        sendAllLabel.text = WStrings.Wallet_SendAmount_SendAll.localized
        sendAllStackView.addArrangedSubview(sendAllLabel)
        let gemIcon = UIImageView(image: UIImage(named: "SendGem"))
        gemIcon.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            gemIcon.widthAnchor.constraint(equalToConstant: 16),
            gemIcon.heightAnchor.constraint(equalToConstant: 16)
        ])
        sendAllStackView.addArrangedSubview(gemIcon)
        allAmountLabel = UILabel()
        if let balance {
            allAmountLabel!.text = formatBalanceText(balance)
        } else {
            sendAllStackView.isHidden = true
        }
        sendAllStackView.addArrangedSubview(allAmountLabel!)
        sendAllStackView.addArrangedSubview(UIView())
        sendAllSwitch = UISwitch()
        sendAllSwitch.addTarget(self, action: #selector(sendAllToggle), for: .valueChanged)
        sendAllStackView.addArrangedSubview(sendAllSwitch)

        // continue button
        continueButton = WButton.setupInstance(.primary)
        continueButton.translatesAutoresizingMaskIntoConstraints = false
        continueButton.setTitle(WStrings.Wallet_SendAmount_Continue.localized, for: .normal)
        continueButton.addTarget(self, action: #selector(continuePressed), for: .touchUpInside)
        continueButton.isEnabled = false
        stackView.addArrangedSubview(continueButton)

        // listen for keyboard
        WKeyboardObserver.observeKeyboard(delegate: self)

        updateTheme()
    }
    
    func updateTheme() {
    }
    
    @objc func editPressed() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func amountContainerPressed() {
        if amountView.isFirstResponder {
            amountView.resignFirstResponder()
        } else {
            amountView.becomeFirstResponder()
        }
    }
    
    @objc func sendAllToggle() {
        if sendAllSwitch.isOn {
            amountView.text = formatBalanceText(balance ?? 0)
            amountView.textViewDidChange(amountView)
        }
    }
    
    @objc func continuePressed() {
        let amount = amountValue(amountView.text)

        let sendConfirmVC = SendConfirmVC(walletContext: walletContext, walletInfo: walletInfo,
                                          addressToSend: addressToSend, amount: amount, sendMode: sendAllSwitch.isOn ? 128 : 3)
        navigationController?.pushViewController(sendConfirmVC, animated: true)
    }
    
    @objc func walletBalanceUpdated(notification: Notification) {
        if let userInfo = notification.userInfo, let balance = userInfo["balance"] as? Int64 {
            if self.balance != balance {
                self.balance = balance
                sendAllStackView.isHidden = balance <= 0
                amountChanged()
            }
        }
    }
}

extension SendAmountVC: WKeyboardObserverDelegate {
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

extension SendAmountVC: WAmountInputDelegate {
    public func amountChanged() {
        let amount = amountValue(amountView.text)
        if let balance, amount > balance {
            insufficientFundsLabel.isHidden = false
            amountView.textColor = WTheme.error
            continueButton.isEnabled = false
        } else {
            insufficientFundsLabel.isHidden = true
            amountView.textColor = WTheme.primaryLabel
            continueButton.isEnabled = true
        }
        sendAllSwitch.isOn = amount == balance
    }
}
