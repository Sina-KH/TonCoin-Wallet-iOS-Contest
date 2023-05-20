//
//  SendingVM.swift
//  UIWalletSend
//
//  Created by Sina on 4/28/23.
//

import Foundation
import WalletContext
import WalletCore
import SwiftSignalKit

protocol SendingVMDelegate: AnyObject {
    func sent(address: String, amount: Int64)
    func errorOccured()
    func canceled()
}

public struct SendInstanceData {
    var decryptedSecret: Data
    var serverSalt: Data
    var destinationAddress: String
    var amount: Int64
    var comment: Data
    var encryptComment: Bool
    var sendMode: Int
    var randomId: Int64
}

class SendingVM {
    private let walletContext: WalletContext
    private let walletInfo: WalletInfo
    private weak var sendingVMDelegate: SendingVMDelegate? = nil
    init(walletContext: WalletContext, walletInfo: WalletInfo, sendingVMDelegate: SendingVMDelegate) {
        self.walletContext = walletContext
        self.walletInfo = walletInfo
        self.sendingVMDelegate = sendingVMDelegate
    }
    
    private let actionDisposable = MetaDisposable()
    deinit {
        actionDisposable.dispose()
    }

    func sendNow(sendInstanceData: SendInstanceData, forceIfDestinationNotInitialized: Bool) {
        let _ = (sendGramsFromWallet(decryptedSecret: sendInstanceData.decryptedSecret,
                                     storage: walletContext.storage,
                                     tonInstance: walletContext.tonInstance,
                                     walletInfo: walletInfo,
                                     localPassword: sendInstanceData.serverSalt,
                                     toAddress: sendInstanceData.destinationAddress,
                                     amount: sendInstanceData.amount,
                                     comment: sendInstanceData.comment,
                                     encryptComment: sendInstanceData.encryptComment,
                                     forceIfDestinationNotInitialized: forceIfDestinationNotInitialized,
                                     sendMode: sendInstanceData.sendMode,
                                     timeout: 0,
                                     randomId: sendInstanceData.randomId)
        |> deliverOnMainQueue).start(next: { [weak self] sentTransaction in
            guard let self else { return }

//            strongSelf.navigationItem.setRightBarButton(UIBarButtonItem(title: strongSelf.presentationData.strings.Wallet_WordImport_Continue, style: .plain, target: strongSelf, action: #selector(strongSelf.sendGramsContinuePressed)), animated: false)
            
            let check = getCombinedWalletState(storage: walletContext.storage,
                                               subject: .wallet(walletInfo),
                                               tonInstance: walletContext.tonInstance,
                                               onlyCached: false)
            |> mapToSignal { state -> Signal<Bool, GetCombinedWalletStateError> in
                switch state {
                case .cached:
                    return .complete()
                case let .updated(state):
                    if !state.pendingTransactions.contains(where: { $0.bodyHash == sentTransaction.bodyHash }) {
                        return .single(true)
                    } else {
                        return .complete()
                    }
                }
            }
            |> then(
                .complete()
                |> delay(3.0, queue: .concurrentDefaultQueue())
            )
            |> restart
            |> take(1)
            
            actionDisposable.set((check
            |> deliverOnMainQueue).start(error: { [weak self] _ in
                guard let self else { return }
                sendingVMDelegate?.sent(address: sendInstanceData.destinationAddress, amount: sendInstanceData.amount)
            }, completed: { [weak self] in
                guard let self else { return }
                sendingVMDelegate?.sent(address: sendInstanceData.destinationAddress, amount: sendInstanceData.amount)
            }
        ))
        }, error: { [weak self] error in
            guard let self else { return }
            
            // as user may go to other pages during the send process, we have to present errors on the top vc of the window
            var title: String?
            let text: String
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
                // destination is not initialized
                if !forceIfDestinationNotInitialized {
                    destinationIsNotInitialized(sendInstanceData: sendInstanceData)
                    return
                } else {
                    text = WStrings.Wallet_SendConfirm_UnknownError.localized
                }
            }
            
            if let vc = topViewController() {
                vc.showAlert(title: title,
                             text: text,
                             button: WStrings.Wallet_Alert_OK.localized) { [weak self] in
                    self?.sendingVMDelegate?.errorOccured()
                }
            }
        })
    }
    
    private func destinationIsNotInitialized(sendInstanceData: SendInstanceData) {
        // as user may go to other pages during the send process,
        //  we have to present errors on the top vc of the window, without relying on the delgate
        guard let vc = topViewController() else { return }
        vc.showAlert(title: WStrings.Wallet_Sending_UninitializedTitle.localized,
                     text: WStrings.Wallet_Sending_UninitializedText.localized,
                     button: WStrings.Wallet_Sending_SendAnyway.localized,
                     buttonPressed: { [weak self] in
            self?.sendNow(sendInstanceData: sendInstanceData, forceIfDestinationNotInitialized: true)
        }, secondaryButton: WStrings.Wallet_Navigation_Cancel.localized) { [weak self] in
            self?.sendingVMDelegate?.canceled()
        }
    }
}
