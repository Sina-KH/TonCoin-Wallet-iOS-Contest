//
//  AppDelegate.swift
//  ToncoinWallet
//
//  Created by Sina on 3/30/23.
//

import UIKit
import UICreateWallet
import SwiftSignalKit
import WalletCore
import UIComponents

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    // wallet context data
    private var walletContext: WalletContextImpl?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.window = UIWindow(frame: UIScreen.main.bounds)

        // set window background color
        if #available(iOS 13.0, *) {
            window?.backgroundColor = .systemBackground
        } else {
            window?.backgroundColor = .white
        }

        // StartVC for users who are using the app for the first time
        let startVC = SplashVC(nibName: "SplashVC", bundle: Bundle(identifier: "org.ton.wallet.UICreateWallet"))
        let navigationController = UINavigationController(rootViewController: startVC)
        self.window?.rootViewController = navigationController

        self.window?.makeKeyAndVisible()
        
        // get wallet data and present correct page on the navigation controller
        startApp(on: navigationController)
        
        return true
    }

    func startApp(on navigationController: UINavigationController) {
        let presentationData = WalletPresentationData(strings: WalletStrings(
                primaryComponent: WalletStringsComponent(
                    languageCode: "en",
                    localizedName: "English",
                    pluralizationRulesCode: "en",
                    dict: [:]
                ),
                secondaryComponent: nil,
                groupingSeparator: " "
            ), dateTimeFormat: WalletPresentationDateTimeFormat(
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
        |> deliverOnMainQueue).start(next: { initialResolvedConfig in
            let walletContext = WalletContextImpl(basePath: documentsPath, storage: storage, config: initialResolvedConfig.config, blockchainName: initialResolvedConfig.networkName, presentationData: presentationData)
            self.walletContext = walletContext

            let beginWithController: (UIViewController) -> Void = { controller in
                let begin: (Bool) -> Void = { animated in
                    navigationController.setViewControllers([controller], animated: false)
                    if animated {
                        navigationController.viewControllers.last?.view.layer.animateAlpha(from: 0.0, to: 1.0, duration: 0.3)
                    }

                    var previousBlockchainName = initialResolvedConfig.networkName

                    let _ = (updatedConfigValue
                    |> deliverOnMainQueue).start(next: { _, blockchainName, blockchainNetwork, config in
                        let _ = walletContext.tonInstance.validateConfig(config: config, blockchainName: blockchainName).start(error: { _ in
                        }, completed: {
                            walletContext.tonInstance.updateConfig(config: config, blockchainName: blockchainName)

                            if previousBlockchainName != blockchainName {
                                previousBlockchainName = blockchainName

//                                let overlayController = OverlayStatusController(theme: presentationData.theme, type: .loading(cancelled: nil))
//                                mainWindow.present(overlayController, on: .root)

//                                let _ = (deleteAllLocalWalletsData(storage: walletContext.storage, tonInstance: walletContext.tonInstance)
//                                |> deliverOnMainQueue).start(error: { [weak overlayController] _ in
//                                    overlayController?.dismiss()
//                                }, completed: { [weak overlayController] in
//                                    overlayController?.dismiss()

//                                    navigationController.setViewControllers([WalletSplashScreen(context: walletContext, blockchainNetwork: blockchainNetwork, mode: .intro, walletCreatedPreloadState: nil)], animated: true)
//                                })
                            }
                        })
                    })
                }

//                if let splashScreen = navigationController.viewControllers.first as? WalletApplicationSplashScreen, let _ = controller as? WalletSplashScreen {
//                    splashScreen.animateOut(completion: {
                        begin(true)
//                    })
//                } else {
//                    begin(false)
//                }
            }

            let _ = (combineLatest(queue: .mainQueue(),
                walletContext.storage.getWalletRecords(),
                walletContext.keychain.encryptionPublicKey()
            )
            |> deliverOnMainQueue).start(next: { records, publicKey in
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
                                if exportCompleted {
//                                    let infoScreen = WalletInfoScreen(context: walletContext, walletInfo: info, blockchainNetwork: initialResolvedConfig.activeNetwork, enableDebugActions: false)
//                                    beginWithController(infoScreen)
//                                    if let url = launchOptions?[UIApplication.LaunchOptionsKey.url] as? URL {
//                                        let walletUrl = parseWalletUrl(url)
//                                        var randomId: Int64 = 0
//                                        arc4random_buf(&randomId, 8)
//                                        let sendScreen = walletSendScreen(context: walletContext, randomId: randomId, walletInfo: info, blockchainNetwork: initialResolvedConfig.activeNetwork, address: walletUrl?.address, amount: walletUrl?.amount, comment: walletUrl?.comment)
//                                        navigationController.pushViewController(sendScreen)
//                                        infoScreen.present(sendScreen, in: .current)
//                                    }
                                } else {
//                                    let createdScreen = WalletSplashScreen(context: walletContext, blockchainNetwork: initialResolvedConfig.activeNetwork, mode: .created(walletInfo: info, words: nil), walletCreatedPreloadState: nil)
//                                    beginWithController(createdScreen)
                                }
                            case let .imported(info):
                                print(".imported")
//                                let createdScreen = WalletSplashScreen(context: walletContext, blockchainNetwork: initialResolvedConfig.activeNetwork, mode: .successfullyImported(importedInfo: info), walletCreatedPreloadState: nil)
//                                beginWithController(createdScreen)
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
                        let startVC = StartVC(nibName: "StartVC", bundle: Bundle(identifier: "org.ton.wallet.UICreateWallet"))
//                        let splashScreen = WalletSplashScreen(context: walletContext, blockchainNetwork: initialResolvedConfig.activeNetwork, mode: .intro, walletCreatedPreloadState: nil)
                        beginWithController(startVC)
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
