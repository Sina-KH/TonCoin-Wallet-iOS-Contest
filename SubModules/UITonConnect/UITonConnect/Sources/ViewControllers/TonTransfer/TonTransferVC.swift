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

    private let walletContext: WalletContext
    private let walletInfo: WalletInfo
    private let dApp: LinkedDApp
    private let requestID: Int64
    private let addressToSend: String
    private let amount: Int64

    private lazy var tonTransferViewModel = TonTransferVM(walletContext: walletContext,
                                                          walletInfo: walletInfo,
                                                          tonTransferVMDelegate: self)
    
    public init(walletContext: WalletContext,
                walletInfo: WalletInfo,
                dApp: LinkedDApp,
                requestID: Int64,
                addressToSend: String,
                amount: Int64) {
        self.walletContext = walletContext
        self.walletInfo = walletInfo
        self.dApp = dApp
        self.requestID = requestID
        self.addressToSend = addressToSend
        self.amount = amount
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
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        tonTransferViewModel.calculateFee(to: addressToSend, amount: amount, comment: "")
    }
    
    private var feeRowView: TitleValueRowView!
    private var confirmButton: WButton!

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
        amountView.balance = amount
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
        let sendGemImage = UIImage(named: "SendGem")!
        feeRowView = TitleValueRowView(title: WStrings.Wallet_SendConfirm_Fee.localized,
                                       value: nil,
                                       valueIcon: sendGemImage,
                                       separator: false)
        fullWidthStackView.addArrangedSubview(feeRowView)
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

        confirmButton = WButton.setupInstance(.primary)
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
        TonConnectCore.sendError(to: dApp.appPublicKey.toHexString(),
                                 walletVersion: walletInfo.version,
                                 error: TonConnectResponseError(id: "\(requestID)",
                                                                error: TonConnectEventErrorPayload(
                                                                    code: TonConnectEventErrorCode.userDeclinedTheConnection,
                                                                    message: "")
                                                               )) { _ in
        }
    }
    
    @objc func sendPressed() {
        isLoading = true
        tonTransferViewModel.calculateFee(to: addressToSend, amount: amount, comment: "", toSend: true)
    }

    var isLoading: Bool = false {
        didSet {
            confirmButton.showLoading = isLoading
            view.isUserInteractionEnabled = !isLoading
        }
    }
}

extension TonTransferVC: TonTransferVMDelegate {
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
                  button: WStrings.Wallet_SendConfirm_ConfirmationConfirm.localized) { [weak self] in
            guard let self else { return }

            authorizeToConfirm { [weak self] in
                guard let self else { return }
                isLoading = true
                tonTransferViewModel.sendConfirmed(address: addressToSend,
                                                   amount: amount,
                                                   comment: "",
                                                   encryptComment: !canNotEncryptComment)
            }
        }
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

    func transferDone() {
        TonConnectCore.sendResponse(to: dApp.appPublicKey.toHexString(),
                                    walletVersion: walletInfo.version,
                                    response: TonConnectResponseSuccess(id: "\(requestID)")) { [weak self] _ in
            guard let self else {
                return
            }
            dismiss(animated: true)
        }
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
