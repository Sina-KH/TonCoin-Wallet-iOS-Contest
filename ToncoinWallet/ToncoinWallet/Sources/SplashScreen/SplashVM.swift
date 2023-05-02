//
//  SplashVM.swift
//  ToncoinWallet
//
//  Created by Sina on 4/21/23.
//

import Foundation
import UICreateWallet
import WalletContext
import WalletCore
import SwiftSignalKit

protocol SplashVMDelegate: AnyObject {
    func errorOccured()
    
    // called when user does not have a wallet yet
    func navigateToIntro(walletContext: WalletContext)
    
    // called when the wallet is created, but not ready yet. user has to check the words, first.
    func navigateToWalletCreated(walletContext: WalletContext, walletInfo: WalletInfo)

    // called when wallet was imported before but the flow didn't finish (left before importing walletInfo)
    func navigateToWalletImported(walletContext: WalletContext, importedWalletInfo: ImportedWalletInfo)
    // called when wallet was imported before but the flow didn't finish (left before setting passcode)
    func navigateToWalletImported(walletContext: WalletContext, walletInfo: WalletInfo)

    // called when the wallet data is complete and user should see wallet home screen (wallet info)
    func navigateToHome(walletContext: WalletContext, walletInfo: WalletInfo)
    
    // called from wallet context if wallet is deleted
    func restartApp()
}

class SplashVM: NSObject {
    
    private weak var splashVMDelegate: SplashVMDelegate?
    init(splashVMDelegate: SplashVMDelegate) {
        self.splashVMDelegate = splashVMDelegate
    }
    
    private var walletContext: WalletContextImpl? = nil

    // get wallet data and present correct page on the navigation controller
    func startApp() {
        let presentationData = WalletPresentationData(
            // TODO:: Move into WalletContext like WStrings and Theme
            dateTimeFormat: WalletPresentationDateTimeFormat(
                timeFormat: .regular,
                dateFormat: .dayFirst,
                dateSeparator: ".",
                decimalSeparator: ".",
                groupingSeparator: " "
            )
        )

        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        #if DEBUG
        print("Starting with \(documentsPath)")
        #endif

        let storage = WalletStorageInterfaceImpl(path: documentsPath + "/data", configurationPath: documentsPath + "/configuration_v2")

        let initialConfigValue = storage.mergedLocalWalletConfiguration()
        |> take(1)
        |> mapToSignal { configuration -> Signal<EffectiveWalletConfiguration?, NoError> in
            if let effective = configuration.effective {
                return .single(effective)
            } else {
                return .single(nil)
            }
        }

        let updatedConfigValue = storage.mergedLocalWalletConfiguration()
        |> mapToSignal { configuration -> Signal<(source: LocalWalletConfigurationSource, blockchainName: String, blockchainNetwork: LocalWalletConfiguration.ActiveNetwork, config: String), NoError> in
            switch configuration.effectiveSource.source {
            case let .url(url):
                guard let parsedUrl = URL(string: url) else {
                    return .complete()
                }
                return Downloader.download(url: parsedUrl)
                |> retry(1.0, maxDelay: 5.0, onQueue: .mainQueue())
                |> mapToSignal { data -> Signal<(source: LocalWalletConfigurationSource, blockchainName: String, blockchainNetwork: LocalWalletConfiguration.ActiveNetwork, config: String), NoError> in
                    if let string = String(data: data, encoding: .utf8) {
                        return .single((source: configuration.effectiveSource.source, blockchainName: configuration.effectiveSource.networkName, blockchainNetwork: configuration.activeNetwork, config: string))
                    } else {
                        return .complete()
                    }
                }
            case let .string(string):
                return .single((source: configuration.effectiveSource.source, blockchainName: configuration.effectiveSource.networkName, blockchainNetwork: configuration.activeNetwork, config: string))
            }
        }
        |> distinctUntilChanged(isEqual: { lhs, rhs in
            if lhs.0 != rhs.0 {
                return false
            }
            if lhs.1 != rhs.1 {
                return false
            }
            if lhs.2 != rhs.2 {
                return false
            }
            if lhs.3 != rhs.3 {
                return false
            }
            return true
        })
        |> afterNext { source, _, _, config in
            let _ = storage.updateMergedLocalWalletConfiguration({ current in
                var current = current
                /*if current.mainNet.configuration.source == source {
                    current.mainNet.resolved = ResolvedLocalWalletConfiguration(source: source, value: config)
                }*/
                if current.testNet.configuration.source == source {
                    current.testNet.resolved = ResolvedLocalWalletConfiguration(source: source, value: config)
                }
                return current
            }).start()
        }

        let resolvedInitialConfig = initialConfigValue
        |> mapToSignal { value -> Signal<EffectiveWalletConfiguration, NoError> in
            if let value = value {
                return .single(value)
            } else {
                return Signal { subscriber in
                    let update = updatedConfigValue.start()
                    let disposable = (storage.mergedLocalWalletConfiguration()
                    |> mapToSignal { configuration -> Signal<EffectiveWalletConfiguration, NoError> in
                        if let effective = configuration.effective {
                            return .single(effective)
                        } else {
                            return .complete()
                        }
                    }
                    |> take(1)).start(next: { next in
                        subscriber.putNext(next)
                    }, completed: {
                        subscriber.putCompletion()
                    })

                    return ActionDisposable {
                        update.dispose()
                        disposable.dispose()
                    }
                }
            }
        }

        let _ = (resolvedInitialConfig
        |> deliverOnMainQueue).start(next: { [weak self] initialResolvedConfig in
            guard let self else {
                return
            }
            guard let splashVMDelegate = splashVMDelegate else {
                return
            }
            let walletContext = WalletContextImpl(basePath: documentsPath,
                                                  storage: storage,
                                                  config: initialResolvedConfig.config,
                                                  blockchainName: initialResolvedConfig.networkName,
                                                  presentationData: presentationData,
                                                  splashVMDelegate: splashVMDelegate)
            self.walletContext = walletContext

            func validateBlockchain(completion: @escaping () -> Void) {
                completion()

                var previousBlockchainName = initialResolvedConfig.networkName

                let _ = (updatedConfigValue
                |> deliverOnMainQueue).start(next: { _, blockchainName, blockchainNetwork, config in
                    let _ = walletContext.tonInstance.validateConfig(config: config, blockchainName: blockchainName).start(error: { _ in
                    }, completed: {
                        walletContext.tonInstance.updateConfig(config: config, blockchainName: blockchainName)

                        if previousBlockchainName != blockchainName {
                            previousBlockchainName = blockchainName

                            let _ = (deleteAllLocalWalletsData(storage: walletContext.storage, tonInstance: walletContext.tonInstance)
                            |> deliverOnMainQueue).start(error: { error in
                                print(error)
                                // Error happened!
                                // TODO::
                            }, completed: { [weak self] in
                                // TODO:: Dismiss all other view controllers
                                // start app again
                                self?.walletContext = nil
                                self?.startApp()
                            })
                        }
                    })
                })
            }
            
            let _ = (combineLatest(queue: .mainQueue(),
                walletContext.storage.getWalletRecords(),
                walletContext.keychain.encryptionPublicKey()
            )
            |> deliverOnMainQueue).start(next: { [weak self] records, publicKey in
                if let record = records.first {
                    if let publicKey = publicKey {
                        let recordPublicKey: Data
                        switch record.info {
                        case let .ready(info, _, _):
                            recordPublicKey = info.encryptedSecret.publicKey
                        case let .imported(info):
                            recordPublicKey = info.encryptedSecret.publicKey
                        }
                        if recordPublicKey == publicKey {
                            switch record.info {
                            case let .ready(info, exportCompleted, _):
                                print(".ready")
                                if exportCompleted == .yes {
                                    validateBlockchain { [weak self] in
                                        self?.splashVMDelegate?.navigateToHome(walletContext: walletContext, walletInfo: info)
                                    }
                                    // TODO:: Handle deeplinks
                                } else {
                                    validateBlockchain { [weak self] in
                                        if exportCompleted == .no(isImport: false) {
                                            self?.splashVMDelegate?.navigateToWalletCreated(walletContext: walletContext, walletInfo: info)
                                        } else {
                                            self?.splashVMDelegate?.navigateToWalletImported(walletContext: walletContext, walletInfo: info)
                                        }
                                    }
                                }
                            case let .imported(info):
                                print(".imported")
                                
                                validateBlockchain { [weak self] in
                                    self?.splashVMDelegate?.navigateToWalletImported(walletContext: walletContext, importedWalletInfo: info)
                                }
                            }
                        } else {
//                            let splashScreen = WalletSplashScreen(context: walletContext, blockchainNetwork: initialResolvedConfig.activeNetwork, mode: .secureStorageReset(.changed), walletCreatedPreloadState: nil)
//                            beginWithController(splashScreen)
                        }
                    } else {
//                        let splashScreen = WalletSplashScreen(context: walletContext, blockchainNetwork: initialResolvedConfig.activeNetwork, mode: WalletSplashMode.secureStorageReset(.notAvailable), walletCreatedPreloadState: nil)
//                        beginWithController(splashScreen)
                    }
                } else {
                    if publicKey != nil {
                        validateBlockchain { [weak self] in
                            self?.splashVMDelegate?.navigateToIntro(walletContext: walletContext)
                        }
                    } else {
                        print("secure storage not available")
//                        let splashScreen = WalletSplashScreen(context: walletContext, blockchainNetwork: initialResolvedConfig.activeNetwork, mode: .secureStorageNotAvailable, walletCreatedPreloadState: nil)
//                        beginWithController(splashScreen)
                    }
                }
            })
        })
    }
}
