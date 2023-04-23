//
//  SendVM.swift
//  UIWalletHome
//
//  Created by Sina on 4/23/23.
//

import Foundation
import WalletContext
import WalletCore
import SwiftSignalKit

protocol SendVMDelegate: AnyObject {
}

class SendVM {
    
    private weak var sendVMDelegate: SendVMDelegate?
    init(sendVMDelegate: SendVMDelegate) {
        self.sendVMDelegate = sendVMDelegate
    }
}
