//
//  TonConnectEventError.swift
//  UITonConnect
//
//  Created by Sina on 5/9/23.
//

import Foundation

// failed to connect dapp error
struct TonConnectEventError: Codable {
    let event: String
    let id: Int64
    let payload: TonConnectEventErrorPayload
    
    public init(event: String, id: Int64, payload: TonConnectEventErrorPayload) {
        self.event = event
        self.id = id
        self.payload = payload
    }
}

public struct TonConnectEventErrorPayload: Codable {
    let code: TonConnectEventErrorCode
    let message: String
    
    init(code: TonConnectEventErrorCode, message: String) {
        self.code = code
        self.message = message
    }
}

public enum TonConnectEventErrorCode: Int, Codable {
    case unknown = 0
    case badRequest = 1
    case manifestNotFound = 2
    case manifestContentError = 3
    case unknownApp = 100
    case userDeclinedTheConnection = 300
    case methodNotSupported = 400
}
