//
//  TonTransferVM.swift
//  UITonConnect
//
//  Created by Sina on 5/10/23.
//

import Foundation
import WalletContext
import SwiftSignalKit

protocol TonTransferVMDelegate: AnyObject {
}

class TonTransferVM {
    
    weak var tonTransferVMDelegate: TonTransferVMDelegate?
    init(tonTransferVMDelegate: TonTransferVMDelegate) {
        self.tonTransferVMDelegate = tonTransferVMDelegate
    }
    
}
