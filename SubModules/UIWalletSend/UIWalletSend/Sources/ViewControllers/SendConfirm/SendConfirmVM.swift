//
//  SendConfirmVM.swift
//  UIWalletSend
//
//  Created by Sina on 4/27/23.
//

import Foundation
import WalletContext
import WalletCore
import SwiftSignalKit

protocol SendConfirmVMDelegate: AnyObject {
    var isLoading: Bool { get set }
    func feeAmountUpdated(fee: Int64)
    func sendConfirmationRequired(fee: Int64, canNotEncryptComment: Bool)
    func navigateToSending(sendInstanceData: SendInstanceData)
    func errorOccured(error: SendGramsFromWalletError)
    func errorOccured(error: TonKeychainDecryptDataError)
}

class SendConfirmVM {
    private let walletContext: WalletContext
    private let walletInfo: WalletInfo
    private weak var sendConfirmVMDelegate: SendConfirmVMDelegate? = nil

    private let serverSaltValue = Promise<Data?>()

    init(walletContext: WalletContext, walletInfo: WalletInfo, sendConfirmVMDelegate: SendConfirmVMDelegate) {
        self.walletContext = walletContext
        self.walletInfo = walletInfo
        self.sendConfirmVMDelegate = sendConfirmVMDelegate
        
        serverSaltValue.set(walletContext.getServerSalt()
        |> map(Optional.init)
        |> `catch` { _ -> Signal<Data?, NoError> in
            return .single(nil)
        })
    }
    
    // latest request data to stop using result if anything changed
    private var latestAmount: Int64? = nil
    private var latestComment: String? = nil
    private var isSending: Bool = false {
        didSet {
            sendConfirmVMDelegate?.isLoading = isSending
        }
    }
    func calculateFee(to destinationAddress: String, amount: Int64, comment: String, toSend: Bool = false) {
        if isSending {
            return
        }
        guard amount > 0 else {
            return
        }
        latestAmount = amount
        latestComment = comment
        isSending = toSend
        let commentData = comment.data(using: .utf8)
        let _ = (verifySendGramsRequestAndEstimateFees(tonInstance: walletContext.tonInstance,
                                                       walletInfo: walletInfo,
                                                       toAddress: destinationAddress,
                                                       amount: amount,
                                                       comment: commentData ?? Data(), encryptComment: false, timeout: 0)
        |> deliverOnMainQueue).start(next: { [weak self] verificationResult in
            guard let self else {return}
            if amount != latestAmount || comment != latestComment  || toSend != isSending {
                // something is already changed
                return
            }
            if toSend {
                isSending = false
            }
            let feeAmount = verificationResult.fees.inFwdFee + verificationResult.fees.storageFee + verificationResult.fees.gasFee + verificationResult.fees.fwdFee
            sendConfirmVMDelegate?.feeAmountUpdated(fee: feeAmount)
            if toSend {
                sendConfirmVMDelegate?.sendConfirmationRequired(fee: feeAmount, canNotEncryptComment: verificationResult.canNotEncryptComment)
            }
        }, error: { [weak self] error in
            guard let self else { return }
            if amount != latestAmount || comment != latestComment || toSend != isSending {
                // comment or amount is already changed
                return
            }
            if toSend {
                isSending = false
            }
            sendConfirmVMDelegate?.errorOccured(error: error)
        })
    }

    func sendConfirmed(address: String, amount: Int64, comment: String, encryptComment: Bool) {
        let progressSignal = Signal<Never, NoError> { subscriber in
            /*let controller = OverlayStatusController(theme: presentationData.theme,  type: .loading(cancelled: nil))
            presentControllerImpl?(controller, nil)*/
            return ActionDisposable { //[weak self] in
                Queue.mainQueue().async() {
                    //controller?.dismiss()
                }
            }
        }
        |> runOn(Queue.mainQueue())
        |> delay(0.15, queue: Queue.mainQueue())
        let progressDisposable = progressSignal.start()

        var serverSaltSignal = serverSaltValue.get()
        |> take(1)

        serverSaltSignal = serverSaltSignal
            |> afterDisposed {
                Queue.mainQueue().async {
                    progressDisposable.dispose()
                }
        }

        let _ = (serverSaltSignal
        |> deliverOnMainQueue).start(next: { [weak self] serverSalt in
            guard let self else { return }

            if let serverSalt = serverSalt {
                if let commentData = comment.data(using: .utf8) {

                    // decrypt wallet secret adn send
                    let _ = (walletContext.keychain.decrypt(walletInfo.encryptedSecret)
                    |> deliverOnMainQueue).start(next: { [weak self] decryptedSecret in
                        guard let self else {
                            return
                        }
                        
                        var randomId: Int64 = 0
                        arc4random_buf(&randomId, 8)
                        let sendInstanceData =  SendInstanceData(decryptedSecret: decryptedSecret,
                                                                 serverSalt: serverSalt,
                                                                 destinationAddress: address,
                                                                 amount: amount,
                                                                 comment: commentData,
                                                                 encryptComment: encryptComment,
                                                                 randomId: randomId)
                        sendConfirmVMDelegate?.navigateToSending(sendInstanceData: sendInstanceData)

                    }, error: { [weak self] error in
                        guard let self else {
                            return
                        }
                        if case .cancelled = error {
                        } else {
                            sendConfirmVMDelegate?.errorOccured(error: error)
                        }
                    })

                }
            }
        })
    }
}

