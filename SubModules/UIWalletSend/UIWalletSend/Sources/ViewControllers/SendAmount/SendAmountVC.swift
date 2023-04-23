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
    let walletContext: WalletContext
    let walletInfo: WalletInfo
    let addressToSend: String
    public init(walletContext: WalletContext, walletInfo: WalletInfo, addressToSend: String) {
        self.walletContext = walletContext
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

    private var stackViewBottomConstraint: NSLayoutConstraint!

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
        sendToLabel.translatesAutoresizingMaskIntoConstraints = false
        let sendToAttributedString = NSMutableAttributedString(string: "\(WStrings.Wallet_SendAmount_SendTo.localized) ",
                                                               attributes: [
                                                                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17, weight: .regular),
                                                                NSAttributedString.Key.foregroundColor: currentTheme.secondaryLabel
        ])
        sendToAttributedString.append(NSAttributedString(string: formatStartEndAddress(addressToSend),
                                                         attributes: [
                                                             NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17, weight: .regular),
                                                             NSAttributedString.Key.foregroundColor: currentTheme.primaryLabel
        ]))
        sendToLabel.attributedText = sendToAttributedString
        sendToStackView.addArrangedSubview(sendToLabel)
        let editButton = WButton.setupInstance(.secondary)
        editButton.translatesAutoresizingMaskIntoConstraints = false
        editButton.setTitle(WStrings.Wallet_SendAmount_Edit.localized, for: .normal)
        sendToStackView.addArrangedSubview(editButton)

        // amount
        let amountContainerView = UIView()
        amountContainerView.translatesAutoresizingMaskIntoConstraints = false
        let amountView = WAmountInput()
        amountView.translatesAutoresizingMaskIntoConstraints = false
        amountContainerView.addSubview(amountView)
        NSLayoutConstraint.activate([
            amountView.centerYAnchor.constraint(equalTo: amountContainerView.centerYAnchor),
            amountView.heightAnchor.constraint(equalToConstant: 56),
            amountView.leftAnchor.constraint(greaterThanOrEqualTo: amountContainerView.leftAnchor, constant: 8),
            amountView.rightAnchor.constraint(lessThanOrEqualTo: amountContainerView.rightAnchor, constant: -8),
            amountView.centerXAnchor.constraint(equalTo: amountContainerView.centerXAnchor)
        ])
        stackView.addArrangedSubview(amountContainerView)

        // send all
        let sendAllStackView = UIStackView()
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
        let allAmountLabel = UILabel()
        allAmountLabel.text = "3.14" // TODO:: Balance here
        sendAllStackView.addArrangedSubview(allAmountLabel)
        sendAllStackView.addArrangedSubview(UIView())
        sendAllStackView.addArrangedSubview(UISwitch())

        // continue button
        let continueButton = WButton.setupInstance(.primary)
        continueButton.translatesAutoresizingMaskIntoConstraints = false
        continueButton.setTitle(WStrings.Wallet_SendAmount_Continue.localized, for: .normal)
        stackView.addArrangedSubview(continueButton)

        // listen for keyboard
        WKeyboardObserver.observeKeyboard(delegate: self)

        updateTheme()
    }
    
    func updateTheme() {
    }
    
    @objc func cancelPressed() {
        dismiss(animated: true)
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
