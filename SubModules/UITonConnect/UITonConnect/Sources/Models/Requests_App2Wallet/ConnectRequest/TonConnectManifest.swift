//
//  TonConnectManifest.swift
//  UITonConnect
//
//  Created by Sina on 5/9/23.
//

import Foundation

public struct TonConnectManifest: Codable {
    let url: String
    let name: String
    let iconUrl: String
    let termsOfUseUrl: String?
    let privacyPolicyUrl: String?
  }
