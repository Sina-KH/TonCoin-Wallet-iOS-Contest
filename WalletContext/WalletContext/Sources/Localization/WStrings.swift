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
    case Wallet_WordCheck_Title = "Wallet.WordCheck.Title"
    case Wallet_WordCheck_Text = "Wallet.WordCheck.Text"
    case Wallet_WordCheck_Continue = "Wallet.WordCheck.Continue"
    case Wallet_WordCheck_IncorrectHeader = "Wallet.WordCheck.IncorrectHeader"
    case Wallet_WordCheck_IncorrectText = "Wallet.WordCheck.IncorrectText"
    case Wallet_WordCheck_TryAgain = "Wallet.WordCheck.TryAgain"
    case Wallet_WordCheck_ViewWords = "Wallet.WordCheck.ViewWords"
    case Wallet_Alert_OK = "Wallet.Alert.OK"
    case Wallet_Completed_Title = "Wallet.Completed.Title"
    case Wallet_Completed_Text = "Wallet.Completed.Text"
    case Wallet_Completed_ViewWallet = "Wallet.Completed.ViewWallet"

    public var localized: String {
        // we can cache strings in a dictionary, if some keys are being reused many times and it's required.
        return NSLocalizedString(rawValue, comment: "")
    }

    public static func Wallet_WordCheck_ViewWords(wordIndices: [Int]) -> String {
        return fillValues(WStrings.Wallet_WordCheck_Text.localized, values: wordIndices.map({ i in
            return "\(i + 1)"
        }))
    }
}

fileprivate func fillValues(_ format: String, values: [String]) -> String {
    var result = format
    for (index, value) in values.enumerated() {
        result = result.replacingOccurrences(of: "%\(index + 1)$@", with: value)
    }
    return result
}
