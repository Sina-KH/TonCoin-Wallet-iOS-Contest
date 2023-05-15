//
//  BridgeEmitter.swift
//  Bridge
//
//  Created by Sina on 5/11/23.
//

import Foundation
import Sodium

public class BridgeEmitter {
    
    private init() {}
    
    public static func emit(url: String,
                            walletPrivateKey: Data,
                            walletPublicKey: String,
                            appPublicKey: String,
                            message: Data,
                            callback: @escaping (Bool) -> Void) {

        // TODO:: Add `topic` as query param.
        //  It can be used by the bridge to deliver the push notification to the wallet.
        //  If the parameter is given, it must correspond to the RPC method called inside the encrypted message.
        guard let url = URL(string: "\(url)/message?client_id=\(walletPublicKey)&to=\(appPublicKey)&ttl=300") else {
            callback(false)
            return
        }

        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let signedData = SessionProtocol.sign(message: [UInt8](message),
                                              recipientPublicKey: Sodium().utils.hex2bin(appPublicKey)!,
                                              privateKey: [UInt8](walletPrivateKey))!
        request.httpBody = Data(bytes: signedData, count: signedData.count)

        // create dataTask using the session object to send data to the server
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Post Request Error: \(error.localizedDescription)")
                callback(false)
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                print("Invalid Response received from the server")
                callback(false)
                return
            }
            callback(true)
        }

        task.resume()
    }
    
}

