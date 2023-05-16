//
//  TonConnectResponse.swift
//  UITonConnect
//
//  Created by Sina on 5/16/23.
//

import Foundation

// success response
public struct TonConnectResponseSuccess: Codable {
    let id: String
}

// error response
public struct TonConnectResponseError: Codable {
    let id: String
    let error: TonConnectEventErrorPayload
}
