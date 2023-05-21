//
//  TonTransferVM.swift
//  UITonConnect
//
//  Created by Sina on 5/10/23.
//

import Foundation
import WalletContext
import WalletCore
import SwiftSignalKit

protocol TonTransferVMDelegate: AnyObject {
    var isLoading: Bool { get set }
    func feeAmountUpdated(fee: Int64)
    func sendConfirmationRequired(fee: Int64, canNotEncryptComment: Bool)
    func transferDone(bocString: String)
    func errorOccured(error: SendGramsFromWalletError)
    func errorOccured(error: TonKeychainDecryptDataError)
}

class TonTransferVM {
    private let walletContext: WalletContext
    private let walletInfo: WalletInfo

    private let serverSaltValue = Promise<Data?>()

    weak var tonTransferVMDelegate: TonTransferVMDelegate?
    init(walletContext: WalletContext, walletInfo: WalletInfo, tonTransferVMDelegate: TonTransferVMDelegate) {
        self.walletContext = walletContext
        self.walletInfo = walletInfo
        self.tonTransferVMDelegate = tonTransferVMDelegate
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
            tonTransferVMDelegate?.isLoading = isSending
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

        var randomId: Int64 = 0
        arc4random_buf(&randomId, 8)
        let _ = (verifySendGramsRequestAndEstimateFees(tonInstance: walletContext.tonInstance,
                                                       walletInfo: walletInfo,
                                                       toAddress: destinationAddress,
                                                       amount: amount,
                                                       comment: commentData ?? Data(),
                                                       encryptComment: false,
                                                       sendMode: 3,
                                                       timeout: 0,
                                                       randomId: randomId)
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
            tonTransferVMDelegate?.feeAmountUpdated(fee: feeAmount)
            if toSend {
                tonTransferVMDelegate?.sendConfirmationRequired(fee: feeAmount, canNotEncryptComment: verificationResult.canNotEncryptComment)
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
            tonTransferVMDelegate?.errorOccured(error: error)
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

                        transferNow(address: address,
                                    amount: amount,
                                    decryptedSecret: decryptedSecret,
                                    serverSalt: serverSalt,
                                    randomId: randomId)

                    }, error: { [weak self] error in
                        guard let self else {
                            return
                        }
                        if case .cancelled = error {
                        } else {
                            tonTransferVMDelegate?.errorOccured(error: error)
                        }
                    })

                }
            }
        })
    }
    // Final step to send tons
    private let actionDisposable = MetaDisposable()
    deinit {
        actionDisposable.dispose()
    }
    private func transferNow(address: String, amount: Int64, decryptedSecret: Data, serverSalt: Data, randomId: Int64) {
        let _ = (walletContext.keychain.decrypt(walletInfo.encryptedSecret)
                 |> deliverOnMainQueue).start(next: { [weak self] decryptedSecret in
            guard let self else {
                return
            }
            let _ = (sendGramsFromWallet(decryptedSecret: decryptedSecret,
                                         storage: walletContext.storage,
                                         tonInstance: walletContext.tonInstance,
                                         walletInfo: walletInfo,
                                         localPassword: serverSalt,
                                         toAddress: address,
                                         amount: amount,
                                         comment: "".data(using: .utf8)!,
                                         encryptComment: false,
                                         forceIfDestinationNotInitialized: true,
                                         sendMode: 3,
                                         timeout: 0,
                                         randomId: randomId)
                     |> deliverOnMainQueue).start(next: { [weak self] (sentTransaction, bocData) in
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
                    }, completed: { [weak self] in
                        guard let self else { return }
                        tonTransferVMDelegate?.transferDone(bocString: bocData.base64EncodedString())
                    }
                ))
            }, error: { [weak self] error in
                guard let self else { return }
                
                tonTransferVMDelegate?.errorOccured(error: error)
            })
        })
    }
    
}

