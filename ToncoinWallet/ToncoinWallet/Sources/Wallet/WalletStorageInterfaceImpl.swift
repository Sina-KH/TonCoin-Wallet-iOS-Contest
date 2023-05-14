import SwiftSignalKit
import WalletCore
import UIKit
import AVFoundation
import UICreateWallet
import WalletContext
import BuildConfig

final class WalletStorageInterfaceImpl: WalletStorageInterface {
    private let storage: FileBackedStorage
    private let configurationStorage: FileBackedStorage
    
    init(path: String, configurationPath: String) {
        self.storage = FileBackedStorage(path: path)
        self.configurationStorage = FileBackedStorage(path: configurationPath)
    }
    
    func watchWalletRecords() -> Signal<[WalletStateRecord], NoError> {
        return self.storage.watch()
        |> map { data -> [WalletStateRecord] in
            guard let data = data else {
                return []
            }
            do {
                return try JSONDecoder().decode(Array<WalletStateRecord>.self, from: data)
            } catch let error {
                print("Error deserializing data: \(error)")
                return []
            }
        }
    }
    
    func getWalletRecords() -> Signal<[WalletStateRecord], NoError> {
        return self.storage.get()
        |> map { data -> [WalletStateRecord] in
            guard let data = data else {
                return []
            }
            do {
                return try JSONDecoder().decode(Array<WalletStateRecord>.self, from: data)
            } catch let error {
                print("Error deserializing data: \(error)")
                return []
            }
        }
    }
    
    func updateWalletRecords(_ f: @escaping ([WalletStateRecord]) -> [WalletStateRecord]) -> Signal<[WalletStateRecord], NoError> {
        return self.storage.update { data -> (Data, [WalletStateRecord]) in
            let records: [WalletStateRecord] = data.flatMap {
                try? JSONDecoder().decode(Array<WalletStateRecord>.self, from: $0)
            } ?? []
            let updatedRecords = f(records)
            do {
                let updatedData = try JSONEncoder().encode(updatedRecords)
                return (updatedData, updatedRecords)
            } catch let error {
                print("Error serializing data: \(error)")
                return (Data(), updatedRecords)
            }
        }
    }
    
    func mergedLocalWalletConfiguration() -> Signal<MergedLocalWalletConfiguration, NoError> {
        return self.configurationStorage.watch()
        |> map { data -> MergedLocalWalletConfiguration in
            guard let data = data, !data.isEmpty else {
                return .default
            }
            do {
                return try JSONDecoder().decode(MergedLocalWalletConfiguration.self, from: data)
            } catch let error {
                print("Error deserializing data: \(error)")
                return .default
            }
        }
    }
    
    func localWalletConfiguration() -> Signal<LocalWalletConfiguration, NoError> {
        return self.mergedLocalWalletConfiguration()
        |> mapToSignal { value -> Signal<LocalWalletConfiguration, NoError> in
            return .single(LocalWalletConfiguration(
                //mainNet: value.mainNet.configuration,
                testNet: value.testNet.configuration,
                activeNetwork: value.activeNetwork
            ))
        }
        |> distinctUntilChanged
    }
    
    func updateMergedLocalWalletConfiguration(_ f: @escaping (MergedLocalWalletConfiguration) -> MergedLocalWalletConfiguration) -> Signal<Never, NoError> {
        return self.configurationStorage.update { data -> (Data, Void) in
            do {
                let current: MergedLocalWalletConfiguration?
                if let data = data, !data.isEmpty {
                    current = try? JSONDecoder().decode(MergedLocalWalletConfiguration.self, from: data)
                } else {
                    current = nil
                }
                let updated = f(current ?? .default)
                let updatedData = try JSONEncoder().encode(updated)
                return (updatedData, Void())
            } catch let error {
                print("Error serializing data: \(error)")
                return (Data(), Void())
            }
        }
        |> ignoreValues
    }
}

final class WalletContextImpl: NSObject, WalletContext, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var storage: WalletStorageInterface {
        return self.storageImpl
    }
    private let storageImpl: WalletStorageInterfaceImpl
    let tonInstance: TonInstance
    let keychain: TonKeychain
    let presentationData: WalletPresentationData
//    let window: Window1
    
    let splashVMDelegate: SplashVMDelegate
    
    let supportsCustomConfigurations: Bool = true
    let termsUrl: String? = nil
    let feeInfoUrl: String? = nil
    
    private var currentImagePickerCompletion: ((UIImage) -> Void)?
    
    var inForeground: Signal<Bool, NoError> {
        return .single(true)
    }
    
    func getServerSalt() -> Signal<Data, WalletContextGetServerSaltError> {
        return .single(Data())
    }
    
    func updateResolvedWalletConfiguration(configuration: LocalWalletConfiguration, source: LocalWalletConfigurationSource, resolvedConfig: String) -> Signal<Never, NoError> {
        return self.storageImpl.updateMergedLocalWalletConfiguration { current in
            var current = current
            //current.mainNet.configuration = configuration.mainNet
            current.testNet.configuration = configuration.testNet
            current.activeNetwork = configuration.activeNetwork
            /*if current.mainNet.configuration.source == source {
                current.mainNet.resolved = ResolvedLocalWalletConfiguration(source: source, value: resolvedConfig)
            }*/
            if current.testNet.configuration.source == source {
                current.testNet.resolved = ResolvedLocalWalletConfiguration(source: source, value: resolvedConfig)
            }
            return current
        }
    }
    
    func presentNativeController(_ controller: UIViewController) {
        topViewController()?.present(controller, animated: true)
    }
    
    func idleTimerExtension() -> Disposable {
        return EmptyDisposable
    }
    
    func openUrl(_ url: String) {
        if let parsedUrl = URL(string: url) {
            UIApplication.shared.open(parsedUrl)
        }
    }
    
    func shareUrl(_ url: String) {
        if let parsedUrl = URL(string: url) {
            self.presentNativeController(UIActivityViewController(activityItems: [parsedUrl], applicationActivities: nil))
        }
    }

    func authorizeAccessToCamera(completion: @escaping (_ granted: Bool) -> Void) {
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { [weak self] response in
            Queue.mainQueue().async {
                guard let strongSelf = self else {
                    return
                }
                
                if response {
                    completion(true)
                } else {
                    completion(false)
                }
            }
        }
    }
    
    func pickImage(completion: @escaping (UIImage) -> Void) {
        self.currentImagePickerCompletion = completion
        
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.allowsEditing = false
        pickerController.mediaTypes = ["public.image"]
        pickerController.sourceType = .photoLibrary
        self.presentNativeController(pickerController)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let currentImagePickerCompletion = self.currentImagePickerCompletion
        self.currentImagePickerCompletion = nil
        picker.presentingViewController?.dismiss(animated: true, completion: {
            if let image = info[.editedImage] as? UIImage {
                currentImagePickerCompletion?(image)
            } else if let image = info[.originalImage] as? UIImage {
                currentImagePickerCompletion?(image)
            }
        })
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.currentImagePickerCompletion = nil
        picker.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    func restartApp() {
        splashVMDelegate.restartApp()
    }

    init(basePath: String,
         storage: WalletStorageInterfaceImpl,
         config: String,
         blockchainName: String,
         presentationData: WalletPresentationData,
         splashVMDelegate: SplashVMDelegate) {
        let _ = try? FileManager.default.createDirectory(at: URL(fileURLWithPath: basePath + "/keys"), withIntermediateDirectories: true, attributes: nil)
        self.storageImpl = storage
        
        self.splashVMDelegate = splashVMDelegate
//        self.window = window
        
        self.tonInstance = TonInstance(
            basePath: basePath + "/keys",
            config: config,
            blockchainName: blockchainName,
            proxy: nil
        )
        
        let baseAppBundleId = Bundle.main.bundleIdentifier!
        
        #if targetEnvironment(simulator)
        self.keychain = TonKeychain(encryptionPublicKey: {
            return .single(Data())
        }, encrypt: { data in
            return .single(TonKeychainEncryptedData(publicKey: Data(), data: data))
        }, decrypt: { data in
            return .single(data.data)
        })
        #else
        self.keychain = TonKeychain(encryptionPublicKey: {
            return Signal { subscriber in
                BuildConfig.getHardwareEncryptionAvailable(withBaseAppBundleId: baseAppBundleId, completion: { value in
                    subscriber.putNext(value)
                    subscriber.putCompletion()
                })
                return EmptyDisposable
            }
        }, encrypt: { data in
            return Signal { subscriber in
                BuildConfig.encryptApplicationSecret(data, baseAppBundleId: baseAppBundleId, completion: { result, publicKey in
                    if let result = result, let publicKey = publicKey {
                        subscriber.putNext(TonKeychainEncryptedData(publicKey: publicKey, data: result))
                        subscriber.putCompletion()
                    } else {
                        subscriber.putError(.generic)
                    }
                })
                return EmptyDisposable
            }
        }, decrypt: { encryptedData in
            return Signal { subscriber in
                BuildConfig.decryptApplicationSecret(encryptedData.data, publicKey: encryptedData.publicKey, baseAppBundleId: baseAppBundleId, completion: { result, cancelled in
                    if let result = result {
                        subscriber.putNext(result)
                    } else {
                        let error: TonKeychainDecryptDataError
                        if cancelled {
                            error = .cancelled
                        } else {
                            error = .generic
                        }
                        subscriber.putError(error)
                    }
                    subscriber.putCompletion()
                })
                return EmptyDisposable
            }
        })
        #endif
        
        self.presentationData = presentationData
        
        super.init()
    }
}
