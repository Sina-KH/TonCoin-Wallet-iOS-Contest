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

struct ResolvedLocalWalletConfiguration: Codable, Equatable {
    var source: LocalWalletConfigurationSource
    var value: String
}

struct MergedLocalBlockchainConfiguration: Codable, Equatable {
    var configuration: WalletCore.LocalBlockchainConfiguration
    var resolved: ResolvedLocalWalletConfiguration?
}

struct EffectiveWalletConfiguration: Equatable {
    let networkName: String
    let config: String
    let activeNetwork: LocalWalletConfiguration.ActiveNetwork
}

struct EffectiveWalletConfigurationSource: Equatable {
    let networkName: String
    let source: LocalWalletConfigurationSource
}

struct MergedLocalWalletConfiguration: Codable, Equatable {
    //var mainNet: MergedLocalBlockchainConfiguration
    var testNet: MergedLocalBlockchainConfiguration
    var activeNetwork: LocalWalletConfiguration.ActiveNetwork
    
    var effective: EffectiveWalletConfiguration? {
        switch self.activeNetwork {
        /*case .mainNet:
            if let resolved = self.mainNet.resolved, resolved.source == self.mainNet.configuration.source {
                return EffectiveWalletConfiguration(networkName: "mainnet", config: resolved.value, activeNetwork: .mainNet)
            } else {
                return nil
            }*/
        case .testNet:
            if let resolved = self.testNet.resolved, resolved.source == self.testNet.configuration.source {
                return EffectiveWalletConfiguration(networkName: self.testNet.configuration.customId ?? "testnet2", config: resolved.value, activeNetwork: .testNet)
            } else {
                return nil
            }
        }
    }
    
    var effectiveSource: EffectiveWalletConfigurationSource {
        switch self.activeNetwork {
        /*case .mainNet:
            return EffectiveWalletConfigurationSource(
                networkName: "mainnet",
                source: self.mainNet.configuration.source
            )*/
        case .testNet:
            return EffectiveWalletConfigurationSource(
                networkName: self.testNet.configuration.customId ?? "testnet2",
                source: self.testNet.configuration.source
            )
        }
    }
}

extension MergedLocalWalletConfiguration {
    static var `default`: MergedLocalWalletConfiguration {
        return MergedLocalWalletConfiguration(
            /*mainNet: MergedLocalBlockchainConfiguration(
                configuration: LocalBlockchainConfiguration(
                    source: .url("https://ton.org/config.json"),
                    customId: nil
                ),
                resolved: nil),*/
            testNet: MergedLocalBlockchainConfiguration(
                configuration: LocalBlockchainConfiguration(
                    source: .url("https://ton.org/global-config-wallet.json"),
                    customId: "mainnet"
                ),
                resolved: nil
            ),
            activeNetwork: .testNet
        )
    }
}
