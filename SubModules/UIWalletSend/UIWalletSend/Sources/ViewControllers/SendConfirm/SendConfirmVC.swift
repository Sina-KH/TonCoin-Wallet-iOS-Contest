//
//  SendConfirmVC.swift
//  UIWalletSend
//
//  Created by Sina on 4/26/23.
//

import UIKit
import UIComponents
import WalletContext
import WalletCore
import UIPasscode

public class SendConfirmVC: WViewController {
    
    // MARK: - Initializer
    private let walletContext: WalletContext
    private let walletInfo: WalletInfo
    private let addressToSend: String
    private let amount: Int64
    private let defaultComment: String?
    private let addressAlias: String?
    public init(walletContext: WalletContext,
                walletInfo: WalletInfo,
                addressToSend: String,
                amount: Int64,
                defaultComment: String? = nil,
                addressAlias: String? = nil) { // address alias can be `raw address` or the `dns address`, we store it with address, to show in recents section.
        self.walletContext = walletContext
        self.walletInfo = walletInfo
        self.addressToSend = addressToSend
        self.amount = amount
        self.defaultComment = defaultComment
        self.addressAlias = addressAlias
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var sendConfirmVM = SendConfirmVM(walletContext: walletContext,
                                                   walletInfo: walletInfo,
                                                   sendConfirmVMDelegate: self)
    
    public override func loadView() {
        super.loadView()
        setupViews()
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        sendConfirmVM.calculateFee(to: addressToSend, amount: amount, comment: "")
    }
    
    private var scrollView: UIScrollView!
    private var commentInput: WCommentInput!
    private var commentWarningLabel: UILabel!
    private var feeRowView: TitleValueRowView!
    private var continueButton: WButton!
    private var continueButtonBottomConstraint: NSLayoutConstraint!

    private func setupViews() {
        navigationItem.title = WStrings.Wallet_Send_Title.localized
        navigationItem.backBarButtonItem = UIBarButtonItem(
            title: WStrings.Wallet_Navigation_Back.localized, style: .plain, target: nil, action: nil
        )

        view.backgroundColor = WTheme.groupedBackground

        // parent scrollView
        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        // hide keyboard on drag
        scrollView.keyboardDismissMode = .interactive
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            // scrollView
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leftAnchor.constraint(equalTo: view.leftAnchor),
            scrollView.rightAnchor.constraint(equalTo: view.rightAnchor),
            // contentLayout
            scrollView.contentLayoutGuide.widthAnchor.constraint(equalTo: view.widthAnchor),
        ])

        // comment label
        let commentTopLabel = UILabel()
        commentTopLabel.translatesAutoresizingMaskIntoConstraints = false
        commentTopLabel.font = .systemFont(ofSize: 13)
        commentTopLabel.textColor = WTheme.secondaryLabel
        commentTopLabel.text = WStrings.Wallet_SendConfirm_Comment.localized
        scrollView.addSubview(commentTopLabel)
        NSLayoutConstraint.activate([
            commentTopLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 22),
            commentTopLabel.leftAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leftAnchor, constant: 32),
            commentTopLabel.rightAnchor.constraint(equalTo: scrollView.contentLayoutGuide.rightAnchor, constant: -32),
        ])
        
        // comment text input
        commentInput = WCommentInput(delegate: self)
        commentInput.placeholderLabel.text = WStrings.Wallet_SendConfirm_CommentPlaceholder.localized
        scrollView.addSubview(commentInput)
        NSLayoutConstraint.activate([
            commentInput.topAnchor.constraint(equalTo: commentTopLabel.bottomAnchor, constant: 4),
            commentInput.leftAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leftAnchor, constant: 16),
            commentInput.rightAnchor.constraint(equalTo: scrollView.contentLayoutGuide.rightAnchor, constant: -16),
        ])

        // comment hint label
        let commentHintLabel = UILabel()
        commentHintLabel.translatesAutoresizingMaskIntoConstraints = false
        commentHintLabel.font = .systemFont(ofSize: 13)
        commentHintLabel.numberOfLines = 0
        commentHintLabel.textColor = WTheme.secondaryLabel
        commentHintLabel.text = WStrings.Wallet_SendConfirm_Hint.localized
        scrollView.addSubview(commentHintLabel)
        NSLayoutConstraint.activate([
            commentHintLabel.topAnchor.constraint(equalTo: commentInput.bottomAnchor, constant: 6),
            commentHintLabel.leftAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leftAnchor, constant: 32),
            commentHintLabel.rightAnchor.constraint(equalTo: scrollView.contentLayoutGuide.rightAnchor, constant: -32),
        ])
        // comment warning label
        commentWarningLabel = UILabel()
        commentWarningLabel.translatesAutoresizingMaskIntoConstraints = false
        commentWarningLabel.font = .systemFont(ofSize: 13)
        commentWarningLabel.numberOfLines = 0
        scrollView.addSubview(commentWarningLabel)
        NSLayoutConstraint.activate([
            commentWarningLabel.topAnchor.constraint(equalTo: commentHintLabel.bottomAnchor, constant: 0),
            commentWarningLabel.leftAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leftAnchor, constant: 32),
            commentWarningLabel.rightAnchor.constraint(equalTo: scrollView.contentLayoutGuide.rightAnchor, constant: -32),
        ])
        
        // LABEL
        let labelLabel = UILabel()
        labelLabel.translatesAutoresizingMaskIntoConstraints = false
        labelLabel.font = .systemFont(ofSize: 13)
        labelLabel.textColor = WTheme.secondaryLabel
        labelLabel.text = WStrings.Wallet_SendConfirm_Label.localized
        scrollView.addSubview(labelLabel)
        NSLayoutConstraint.activate([
            labelLabel.topAnchor.constraint(equalTo: commentWarningLabel.bottomAnchor, constant: 28),
            labelLabel.leftAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leftAnchor, constant: 32),
            labelLabel.rightAnchor.constraint(equalTo: scrollView.contentLayoutGuide.rightAnchor, constant: -32),
        ])
        
        // Label View
        let labelView = UIView()
        labelView.translatesAutoresizingMaskIntoConstraints = false
        labelView.backgroundColor = WTheme.background
        labelView.layer.cornerRadius = 10
        scrollView.addSubview(labelView)
        NSLayoutConstraint.activate([
            labelView.topAnchor.constraint(equalTo: labelLabel.bottomAnchor, constant: 4),
            labelView.leftAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leftAnchor, constant: 16),
            labelView.rightAnchor.constraint(equalTo: scrollView.contentLayoutGuide.rightAnchor, constant: -16),
            labelView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -70)
        ])
        let labelStackView = UIStackView()
        labelStackView.translatesAutoresizingMaskIntoConstraints = false
        labelStackView.axis = .vertical
        let sendGemImage = UIImage(named: "SendGem")!
        labelStackView.addArrangedSubview(TitleValueRowView(title: WStrings.Wallet_SendConfirm_Recipient.localized,
                                                            value: formatStartEndAddress(addressToSend)))
        labelStackView.addArrangedSubview(TitleValueRowView(title: WStrings.Wallet_SendConfirm_Amount.localized,
                                                            value: formatBalanceText(amount),
                                                            valueIcon: sendGemImage))
        feeRowView = TitleValueRowView(title: WStrings.Wallet_SendConfirm_Fee.localized,
                                           value: nil,
                                           valueIcon: sendGemImage,
                                           separator: false)
        labelStackView.addArrangedSubview(feeRowView)
        labelView.addSubview(labelStackView)
        NSLayoutConstraint.activate([
            labelStackView.leftAnchor.constraint(equalTo: labelView.leftAnchor),
            labelStackView.topAnchor.constraint(equalTo: labelView.topAnchor),
            labelStackView.rightAnchor.constraint(equalTo: labelView.rightAnchor),
            labelStackView.bottomAnchor.constraint(equalTo: labelView.bottomAnchor)
        ])

        // continue button
        continueButton = WButton.setupInstance(.primary)
        continueButton.translatesAutoresizingMaskIntoConstraints = false
        continueButton.setTitle(WStrings.Wallet_SendConfirm_ConfirmAndSend.localized, for: .normal)
        continueButton.addTarget(self, action: #selector(continuePressed), for: .touchUpInside)
        view.addSubview(continueButton)
        continueButtonBottomConstraint = continueButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12)
        NSLayoutConstraint.activate([
            continueButton.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16),
            continueButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -16),
            continueButtonBottomConstraint
        ])

        if let defaultComment {
            commentInput.text = defaultComment
            commentTextChanged()
        }

        // listen for keyboard
        WKeyboardObserver.observeKeyboard(delegate: self)
    }
    
    @objc private func continuePressed() {
        view.endEditing(true)
        UnlockVC.presentAuth(on: self, onAuth: { [weak self] in
            guard let self else {
                return
            }
            sendConfirmVM.calculateFee(to: addressToSend, amount: amount, comment: commentInput.text, toSend: true)
        })
    }
    
    var isLoading: Bool = false {
        didSet {
            continueButton.showLoading = isLoading
            view.isUserInteractionEnabled = !isLoading
        }
    }
}

extension SendConfirmVC: WCommentInputDelegate {
    public func commentTextChanged() {
        let comment = commentInput.text ?? ""
        // check if comment is too long
        if comment.count > walletTextLimit {
            commentWarningLabel.textColor = WTheme.error
            commentWarningLabel.text = WStrings.Wallet_SendConfirm_HintMessageSizeExceeded(chars: comment.count - walletTextLimit)
            return
        }
        
        if walletTextLimit - comment.count < 25 {
            commentWarningLabel.textColor = WTheme.warning
            commentWarningLabel.text = WStrings.Wallet_SendConfirm_HintMessageCharactersLeft(chars: walletTextLimit - comment.count)
        } else {
            commentWarningLabel.text = nil
        }

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) { [weak self] in
            guard let self else {
                return
            }
            if commentInput.text ?? "" == comment {
                sendConfirmVM.calculateFee(to: addressToSend, amount: amount, comment: comment)
            }
        }
    }
}

extension SendConfirmVC: WKeyboardObserverDelegate {
    public func keyboardWillShow(height: CGFloat) {
        scrollView.contentInset.bottom = height + 20
        
        if continueButtonBottomConstraint.constant != -height - 12 {
            UIView.animate(withDuration: 0.25) {
                self.continueButtonBottomConstraint.constant = -height - 12
                self.view.layoutIfNeeded()
            }
        }
    }
    
    public func keyboardWillHide() {
        scrollView.contentInset.bottom = 0

        if continueButtonBottomConstraint.constant != -12 {
            UIView.animate(withDuration: 0.25) {
                self.continueButtonBottomConstraint.constant = -12
                self.view.layoutIfNeeded()
            }
        }
    }
}

extension SendConfirmVC: SendConfirmVMDelegate {
    func feeAmountUpdated(fee: Int64) {
        feeRowView.setValueText("≈ \(formatBalanceText(fee))")
    }
    func sendConfirmationRequired(fee: Int64, canNotEncryptComment: Bool) {
        let amountString = formatBalanceText(amount)
        let feeString = formatBalanceText(fee)
        
        let textAttr = WStrings.Wallet_SendConfirm_ConfirmationText(
            textAttr: [
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13)
            ],
            address: NSAttributedString(string: addressToSend, attributes: [
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13, weight: .semibold)
            ]),
            amount: NSAttributedString(string: amountString, attributes: [
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .semibold)
            ]),
            fee: NSAttributedString(string: feeString, attributes: [
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13, weight: .semibold)
            ])
        )
        if canNotEncryptComment {
            textAttr.append(NSAttributedString(string: "\n\n\(WStrings.Wallet_SendConfirm_CommentNotEncrypted)", attributes: [
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13, weight: .regular)
            ]))
        }

        showAlert(title: WStrings.Wallet_SendConfirm_Confirmation.localized,
                  textAttr: textAttr,
                  button: WStrings.Wallet_SendConfirm_ConfirmationConfirm.localized, buttonPressed: { [weak self] in
            guard let self else { return }

            authorizeToConfirm { [weak self] in
                guard let self else { return }
                sendConfirmVM.sendConfirmed(address: addressToSend,
                                            amount: amount,
                                            comment: commentInput.text,
                                            encryptComment: !canNotEncryptComment)
            }
        }, secondaryButton: WStrings.Wallet_Navigation_Cancel.localized, preferPrimary: false)
    }

    // authorize and then finalize the pre-send process
    private func authorizeToConfirm(onAuth: @escaping () -> Void) {
        onAuth()
        return
        
        // onAuth() function will ask for authentication because of keychain lock!

        /*let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = WStrings.Wallet_Biometric_Reason.localized

            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) {
                [weak self] success, authenticationError in

                DispatchQueue.main.async { [weak self] in
                    if success {
                        onAuth()
                    } else {
                        // error
                        self?.present(UnlockVC(onAuth: onAuth), animated: true)
                    }
                }
            }
        } else {
            present(UnlockVC(onAuth: onAuth), animated: true)
        }*/
    }

    // navigate to sending page and send!
    func navigateToSending(sendInstanceData: SendInstanceData) {
        // add `address` and `address alias` to recents
        let recentAddress = RecentAddress(address: addressToSend, addressAlias: addressAlias, timstamp: Date().timeIntervalSince1970)
        RecentAddressesHelpers.saveRecentAddress(recentAddress: recentAddress, walletVersion: walletInfo.version)
        // navigate to send
        navigationController?.pushViewController(SendingVC(walletContext: walletContext,
                                                           walletInfo: walletInfo,
                                                           sendInstanceData: sendInstanceData),
                                                 animated: true)
    }

    // error occured
    func errorOccured(error: SendGramsFromWalletError) {
        var title: String? = nil
        var text = ""
        switch error {
        case .generic:
            text = WStrings.Wallet_SendConfirm_UnknownError.localized
        case .network:
            title = WStrings.Wallet_SendConfirm_NetworkErrorTitle.localized
            text = WStrings.Wallet_SendConfirm_NetworkErrorText.localized
        case .notEnoughFunds:
            title = WStrings.Wallet_SendConfirm_ErrorNotEnoughFundsTitle.localized
            text = WStrings.Wallet_SendConfirm_ErrorNotEnoughFundsText.localized
        case .messageTooLong:
            text = WStrings.Wallet_SendConfirm_UnknownError.localized
        case .invalidAddress:
            text = WStrings.Wallet_SendConfirm_ErrorInvalidAddress.localized
        case .secretDecryptionFailed:
            text = WStrings.Wallet_SendConfirm_ErrorDecryptionFailed.localized
        case .destinationIsNotInitialized:
            text = WStrings.Wallet_SendConfirm_UnknownError.localized
        }
        showAlert(title: title, text: text, button: WStrings.Wallet_Alert_OK.localized)
        feeRowView.setValueText("")
    }
    
    func errorOccured(error: TonKeychainDecryptDataError) {
        switch error {
        case .cancelled:
            break
        default:
            showAlert(title: nil,
                      text: WStrings.Wallet_SendConfirm_ErrorDecryptionFailed.localized,
                      button: WStrings.Wallet_Alert_OK.localized)
        }
    }
}
