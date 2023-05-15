//
//  TonConnectEventSuccess.swift
//  UITonConnect
//
//  Created by Sina on 5/9/23.
//

import Foundation

struct TonConnectEventSuccess: TonConnectEvent, Codable {
    let event: String
    let id: Int
    let payload: TonConnectEventSuccessPayload

    init(id: Int, payload: TonConnectEventSuccessPayload) {
        self.event = "connect"
        self.id = id
        self.payload = payload
    }
}

struct TonConnectEventSuccessPayload: Codable {
    let items: [TonConnectItemReplyAddr]
    let device: TonConnectEventSuccessPayloadDeviceInfo
}

// all the replies implement a name
protocol TonConnectItemReply: Codable {
    var name: String { get }
}

// `ton_addr` reply specific struct
struct TonConnectItemReplyAddr: TonConnectItemReply, Codable {
    let name: String

    // `ton_addr` item reply
    let address: String // TON address raw (`0:<hex>`)
    let network: TonNetwork // network global_id
    let publicKey: String // HEX string without 0x
    let walletStateInit: String // Base64 (not url safe) encoded stateinit cell for the wallet contract

    init(address: String, network: TonNetwork, publicKey: String, walletStateInit: String) {
        self.name = "ton_addr"
        self.address = address
        self.network = network
        self.publicKey = publicKey
        self.walletStateInit = walletStateInit
    }
}

// used for methods not supported. (for example `ton_proof`)
struct ConnectItemReplyErrorNotSupported: TonConnectItemReply, Codable {
    let name: String
    let error: TonConnectItemError
    
    init(name: String) {
        self.name = name
        self.error = TonConnectItemError(code: .methodNotSupported, message: nil)
    }
}

// ton connect item errors generally contain a code and a message
struct TonConnectItemError: Codable {
    let code: TonConnectItemErrorCode
    let message: String?
}

// specific error related to `ton_addr`
struct TonConnectItemReplyAddrError: TonConnectItemReply, Codable {
    let name: String
    let error: TonConnectItemErrorCode
    
    init(error: TonConnectItemErrorCode) {
        self.name = "ton_addr"
        self.error = error
    }
}

enum TonConnectItemErrorCode: Int, Codable {
    case unknown = 0
    case methodNotSupported = 400
}

/*struct TonConnectItemReplyProof: TonConnectItemReply {
    let name: String

    struct ProofObj {
        struct Domain {
            let lengthBytes: Int // AppDomain Length
            let value: String // app domain name (as url part, without encoding)
            
            init(lengthBytes: Int, value: String) {
                self.lengthBytes = lengthBytes
                self.value = value
            }
        }
        let timestamp: String // 64-bit unix epoch time of the signing operation (seconds)
        let domain: Domain
        let signature: String // base64-encoded signature
        let payload: String // payload from the request
        
        init(timestamp: String, domain: Domain, signature: String, payload: String) {
            self.timestamp = timestamp
            self.domain = domain
            self.signature = signature
            self.payload = payload
        }
    }
    
    let proof: ProofObj
    
    init(proof: ProofObj) {
        self.name = "ton_proof"
        self.proof = proof
    }
}*/

enum TonNetwork: Int, Codable {
    case mainnet = -239
    case testnet = -3
}

struct TonConnectEventSuccessPayloadDeviceInfo: Codable {
    enum Platform: String, Codable {
        case iPhone = "iphone"
        case iPad = "iPad"
        case mac = "mac"
    }

    let platform: Platform
    let appName: String
    let appVersion: String
    let maxProtocolVersion: Int
    let features: [String]//TonConnectFeature
}

struct TonConnectFeature: Codable {
    let name: String
    let maxMessages: Int
}
