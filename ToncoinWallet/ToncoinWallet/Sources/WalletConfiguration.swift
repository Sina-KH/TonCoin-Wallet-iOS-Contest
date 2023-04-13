import Foundation
import UIKit
import SwiftSignalKit
import WalletCore
import UIKit

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
