//
//  WStrings.swift
//  WalletContext
//
//  Created by Sina on 4/14/23.
//

import Foundation

public enum WStrings: String {
    case Wallet_Intro_ImportExisting = "Wallet.Intro.ImportExisting"
    case Wallet_Intro_CreateErrorTitle = "Wallet.Intro.CreateErrorTitle"
    case Wallet_Intro_CreateErrorText = "Wallet.Intro.CreateErrorText"
    case Wallet_Intro_Title = "Wallet.Intro.Title"
    case Wallet_Intro_Text = "Wallet.Intro.Text"
    case Wallet_Intro_CreateWallet = "Wallet.Intro.CreateWallet"
    case Wallet_Created_Title = "Wallet.Created.Title"
    case Wallet_Created_Text = "Wallet.Created.Text"
    case Wallet_Created_Proceed = "Wallet.Created.Proceed"
    case Wallet_Created_ExportErrorTitle = "Wallet.Created.ExportErrorTitle"
    case Wallet_Created_ExportErrorText = "Wallet.Created.ExportErrorText"
    case Wallet_Words_Title = "Wallet.Words.Title"
    case Wallet_Words_Text = "Wallet.Words.Text"
    case Wallet_Words_Done = "Wallet.Words.Done"
    case Wallet_Words_NotDoneTitle = "Wallet.Words.NotDoneTitle"
    case Wallet_Words_NotDoneText = "Wallet.Words.NotDoneText"
    case Wallet_Words_NotDoneOk = "Wallet.Words.NotDoneOk"
    case Wallet_Words_NotDoneResponse = "Wallet.Words.NotDoneResponse"
    case Wallet_Words_NotDoneSkip = "Wallet.Words.NotDoneSkip"
    
    case Wallet_Alert_OK = "Wallet.Alert.OK"

    public var localized: String {
        return NSLocalizedString(rawValue, comment: "")
    }
}
