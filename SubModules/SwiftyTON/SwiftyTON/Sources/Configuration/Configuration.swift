//
//  Created by Anton Spivak
//

import Foundation


//public struct Configuration {
//    
//    public let network: Network
//    public let logging: Logging
//    public let keystoreURL: URL
//    
//    public init(
//        network: Network,
//        logging: Logging,
//        keystoreURL: URL
//    ) {
//        self.network = network
//        self.logging = logging
//        self.keystoreURL = keystoreURL
//    }
//}

//internal extension GTTONConfiguration {
//
//    static func with(
//        _ configuration: Configuration,
//        reload: Bool
//    ) async -> GTTONConfiguration {
//        self.init(
//            networkName: configuration.network.rawValue,
//            jsonString: await configuration.network.contents(
//                reloaded: reload
//            ),
//            keystoreURL: configuration.keystoreURL,
//            logging: {
//                switch configuration.logging {
//                case .plain: return .plain
//                case .fatal: return .fatal
//                case .error: return .error
//                case .warning: return .warning
//                case .info: return .info
//                case .debug: return .debug
//                case .never: return .never
//                }
//            }()
//        )
//    }
//}
