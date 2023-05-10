//
//  TonConnectEventError.swift
//  UITonConnect
//
//  Created by Sina on 5/9/23.
//

import Foundation

struct TonConnectEventError {
    let event: String
    let id: Int
    let payload: TonConnectEventErrorPayload
    
    init(id: Int, payload: TonConnectEventErrorPayload) {
        self.event = "connect_error"
        self.id = id
        self.payload = payload
    }
}

struct TonConnectEventErrorPayload {
    let code: TonConnectEventErrorCode
    let message: String
    
    init(code: TonConnectEventErrorCode, message: String) {
        self.code = code
        self.message = message
    }
}

enum TonConnectEventErrorCode: Int {
    case unknown = 0
    case badRequest = 1
    case manifestNotFound = 2
    case manifestContentError = 3
    case unknownApp = 100
    case userDeclinedTheConnection = 300
}
