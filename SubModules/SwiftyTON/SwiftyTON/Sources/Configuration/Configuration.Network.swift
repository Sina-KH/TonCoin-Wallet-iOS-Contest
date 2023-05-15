//
//  File.swift
//  
//
//  Created by Anton Spivak on 06.06.2022.
//

import Foundation

//public extension Configuration {
//
//    enum Network: String {
//
//        case main = "mainnet"
//        case test = "testnet"
//    }
//}
//
//public extension Configuration.Network {
//
//    var configurationURL: URL {
//        let url: URL?
//        switch self {
//        case .main:
//            url = URL(string: "https://ton.org/global-config.json")
//        case .test:
//            url = URL(string: "https://ton-blockchain.github.io/testnet-global.config.json")
//        }
//
//        guard let url = url
//        else {
//            fatalError(URLError(.badURL).localizedDescription)
//        }
//
//        return url
//    }
//
//    /// - parameter reload: If yes will try to update configuration from `configurationURL`
//    /// - returns: Network configuration downloaded from network or cached if `reload` is false
//    func contents(
//        reloaded: Bool
//    ) async -> String {
//        guard reloaded
//        else {
//            return contentsCachedElseBundled
//        }
//
//        let request = URLRequest(url: configurationURL)
//        let string: String
//
//        do {
//            let (data, _) = try await URLSession.shared._data(for: request)
//            guard let value = String(data: data, encoding: .utf8)?.JSONMinify, !value.isEmpty
//            else {
//                throw URLError(.badServerResponse)
//            }
//
//            cache(data: data)
//
//            string = value
//        } catch {
//            string = contentsCachedElseBundled
//        }
//
//        return string
//    }
//}
//
//private extension Configuration.Network {
//
//    var fileName: String {
//        switch self {
//        case .main:
//            return "mainnet"
//        case .test:
//            return "testnet"
//        }
//    }
//
//    /// - returns: URL of file that stored at bundle
//    var bundleFileURL: URL {
//        guard let url = Bundle(for: Self.self).url(forResource: fileName, withExtension: nil, subdirectory: "Configurations")
//        else {
//            fatalError(URLError(.badURL).localizedDescription)
//        }
//        return url
//    }
//
//    /// - returns: URL of file that stored at user documents directory
//    var documentsFileURL: URL {
//        let fileManager = FileManager.default
//        let directoryURL = fileManager
//            .urls(for: .documentDirectory, in: .userDomainMask)[0]
//            .appendingPathComponent("SwiftyTON/Configurations/", isDirectory: true)
//
//        let fileURL = directoryURL.appendingPathComponent(fileName, isDirectory: false)
//        if !fileManager.fileExists(atPath: directoryURL.relativePath, isDirectory: nil) {
//            try? fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
//        }
//
//        return fileURL
//    }
//
//    /// - returns: Data from last saved file at documents direcortory or bundle file
//    private var contentsCachedElseBundled: String {
//        let data: Data
//        do {
//            let _data = try Data(contentsOf: documentsFileURL)
//            guard !_data.isEmpty
//            else {
//                throw URLError(.fileDoesNotExist)
//            }
//            data = _data
//        } catch {
//            do {
//                data = try Data(contentsOf: bundleFileURL)
//            } catch {
//                fatalError(URLError(.fileDoesNotExist).localizedDescription)
//            }
//        }
//
//        guard let string = String(data: data, encoding: .utf8)?.JSONMinify
//        else {
//            fatalError(CocoaError(.fileReadUnknownStringEncoding).localizedDescription)
//        }
//
//        return string
//    }
//
//    func cache(data: Data) {
//        do {
//            try data.write(to: documentsFileURL)
//        } catch {
//            return
//        }
//    }
//}
