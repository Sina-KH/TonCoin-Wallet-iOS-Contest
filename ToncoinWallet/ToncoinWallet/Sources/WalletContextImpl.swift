////
////  WalletContextImpl.swift
////  ToncoinWallet
////
////  Created by Sina on 4/7/23.
////
//
//import Foundation
//import WalletCore
//import WalletUrl
//import SwiftSignalKit
//import UIKit
//import AVFoundation
//
//final class WalletContextImpl: NSObject, WalletContext, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
//    var storage: WalletStorageInterface {
//        return self.storageImpl
//    }
//    private let storageImpl: WalletStorageInterfaceImpl
//    let tonInstance: TonInstance
//    let keychain: TonKeychain
//    let presentationData: WalletPresentationData
//    let window: Window1
//    
//    let supportsCustomConfigurations: Bool = true
//    let termsUrl: String? = nil
//    let feeInfoUrl: String? = nil
//    
//    private var currentImagePickerCompletion: ((UIImage) -> Void)?
//    
//    var inForeground: Signal<Bool, NoError> {
//        return .single(true)
//    }
//    
//    func getServerSalt() -> Signal<Data, WalletContextGetServerSaltError> {
//        return .single(Data())
//    }
//    
//    func downloadFile(url: URL) -> Signal<Data, WalletDownloadFileError> {
//        return download(url: url)
//        |> mapError { _ in
//            return .generic
//        }
//    }
//    
//    func updateResolvedWalletConfiguration(configuration: LocalWalletConfiguration, source: LocalWalletConfigurationSource, resolvedConfig: String) -> Signal<Never, NoError> {
//        return self.storageImpl.updateMergedLocalWalletConfiguration { current in
//            var current = current
//            //current.mainNet.configuration = configuration.mainNet
//            current.testNet.configuration = configuration.testNet
//            current.activeNetwork = configuration.activeNetwork
//            /*if current.mainNet.configuration.source == source {
//                current.mainNet.resolved = ResolvedLocalWalletConfiguration(source: source, value: resolvedConfig)
//            }*/
//            if current.testNet.configuration.source == source {
//                current.testNet.resolved = ResolvedLocalWalletConfiguration(source: source, value: resolvedConfig)
//            }
//            return current
//        }
//    }
//    
//    func presentNativeController(_ controller: UIViewController) {
//        self.window.presentNative(controller)
//    }
//    
//    func idleTimerExtension() -> Disposable {
//        return EmptyDisposable
//    }
//    
//    func openUrl(_ url: String) {
//        if let parsedUrl = URL(string: url) {
//            UIApplication.shared.openURL(parsedUrl)
//        }
//    }
//    
//    func shareUrl(_ url: String) {
//        if let parsedUrl = URL(string: url) {
//            self.presentNativeController(UIActivityViewController(activityItems: [parsedUrl], applicationActivities: nil))
//        }
//    }
//    
//    func openPlatformSettings() {
//        if let url = URL(string: UIApplication.openSettingsURLString) {
//            UIApplication.shared.openURL(url)
//        }
//    }
//    
//    func authorizeAccessToCamera(completion: @escaping () -> Void) {
//        AVCaptureDevice.requestAccess(for: AVMediaType.video) { [weak self] response in
//            Queue.mainQueue().async {
//                guard let strongSelf = self else {
//                    return
//                }
//                
//                if response {
//                    completion()
//                } else {
//                    let presentationData = strongSelf.presentationData
//                    let controller = standardTextAlertController(theme: presentationData.theme.alert, title: presentationData.strings.Wallet_AccessDenied_Title, text: presentationData.strings.Wallet_AccessDenied_Camera, actions: [TextAlertAction(type: .defaultAction, title: presentationData.strings.Wallet_Intro_NotNow, action: {}), TextAlertAction(type: .genericAction, title: presentationData.strings.Wallet_AccessDenied_Settings, action: {
//                        strongSelf.openPlatformSettings()
//                    })])
//                    strongSelf.window.present(controller, on: .root)
//                }
//            }
//        }
//    }
//    
//    func pickImage(present: @escaping (ViewController) -> Void, completion: @escaping (UIImage) -> Void) {
//        self.currentImagePickerCompletion = completion
//        
//        let pickerController = UIImagePickerController()
//        pickerController.delegate = self
//        pickerController.allowsEditing = false
//        pickerController.mediaTypes = ["public.image"]
//        pickerController.sourceType = .photoLibrary
//        self.presentNativeController(pickerController)
//    }
//    
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//        let currentImagePickerCompletion = self.currentImagePickerCompletion
//        self.currentImagePickerCompletion = nil
//        if let image = info[.editedImage] as? UIImage {
//            currentImagePickerCompletion?(image)
//        } else if let image = info[.originalImage] as? UIImage {
//            currentImagePickerCompletion?(image)
//        }
//        picker.presentingViewController?.dismiss(animated: true, completion: nil)
//    }
//    
//    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//        self.currentImagePickerCompletion = nil
//        picker.presentingViewController?.dismiss(animated: true, completion: nil)
//    }
//    
//    init(basePath: String, storage: WalletStorageInterfaceImpl, config: String, blockchainName: String, presentationData: WalletPresentationData, navigationBarTheme: NavigationBarTheme, window: Window1) {
//        let _ = try? FileManager.default.createDirectory(at: URL(fileURLWithPath: basePath + "/keys"), withIntermediateDirectories: true, attributes: nil)
//        self.storageImpl = storage
//        
//        self.window = window
//        
//        self.tonInstance = TonInstance(
//            basePath: basePath + "/keys",
//            config: config,
//            blockchainName: blockchainName,
//            proxy: nil
//        )
//        
//        let baseAppBundleId = Bundle.main.bundleIdentifier!
//        
//        #if targetEnvironment(simulator)
//        self.keychain = TonKeychain(encryptionPublicKey: {
//            return .single(Data())
//        }, encrypt: { data in
//            return .single(TonKeychainEncryptedData(publicKey: Data(), data: data))
//        }, decrypt: { data in
//            return .single(data.data)
//        })
//        #else
//        self.keychain = TonKeychain(encryptionPublicKey: {
//            return Signal { subscriber in
//                BuildConfig.getHardwareEncryptionAvailable(withBaseAppBundleId: baseAppBundleId, completion: { value in
//                    subscriber.putNext(value)
//                    subscriber.putCompletion()
//                })
//                return EmptyDisposable
//            }
//        }, encrypt: { data in
//            return Signal { subscriber in
//                BuildConfig.encryptApplicationSecret(data, baseAppBundleId: baseAppBundleId, completion: { result, publicKey in
//                    if let result = result, let publicKey = publicKey {
//                        subscriber.putNext(TonKeychainEncryptedData(publicKey: publicKey, data: result))
//                        subscriber.putCompletion()
//                    } else {
//                        subscriber.putError(.generic)
//                    }
//                })
//                return EmptyDisposable
//            }
//        }, decrypt: { encryptedData in
//            return Signal { subscriber in
//                BuildConfig.decryptApplicationSecret(encryptedData.data, publicKey: encryptedData.publicKey, baseAppBundleId: baseAppBundleId, completion: { result, cancelled in
//                    if let result = result {
//                        subscriber.putNext(result)
//                    } else {
//                        let error: TonKeychainDecryptDataError
//                        if cancelled {
//                            error = .cancelled
//                        } else {
//                            error = .generic
//                        }
//                        subscriber.putError(error)
//                    }
//                    subscriber.putCompletion()
//                })
//                return EmptyDisposable
//            }
//        })
//        #endif
//        
//        self.presentationData = presentationData
//        
//        super.init()
//    }
//}
