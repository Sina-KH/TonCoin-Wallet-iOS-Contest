import Foundation
import UIKit
import SwiftSignalKit
import WalletCore
import UIKit

public enum WalletContextGetServerSaltError {
    case generic
}

public enum WalletDownloadFileError {
    case generic
}

public protocol WalletContext {
    var storage: WalletStorageInterface { get }
    var tonInstance: TonInstance { get }
    var keychain: TonKeychain { get }
    var presentationData: WalletPresentationData { get }
    
    var supportsCustomConfigurations: Bool { get }
    var termsUrl: String? { get }
    var feeInfoUrl: String? { get }
    
    var inForeground: Signal<Bool, NoError> { get }
    
    func getServerSalt() -> Signal<Data, WalletContextGetServerSaltError>
    func downloadFile(url: URL) -> Signal<Data, WalletDownloadFileError>
    
    func updateResolvedWalletConfiguration(configuration: LocalWalletConfiguration, source: LocalWalletConfigurationSource, resolvedConfig: String) -> Signal<Never, NoError>
    
    func presentNativeController(_ controller: UIViewController)
    
    func idleTimerExtension() -> Disposable
    func openUrl(_ url: String)
    func shareUrl(_ url: String)
    func openPlatformSettings()
    func authorizeAccessToCamera(completion: @escaping () -> Void)
    func pickImage(present: @escaping (UIViewController) -> Void, completion: @escaping (UIImage) -> Void)
}
