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
    case Wallet_Completed_Title = "Wallet.Completed.Title"
    case Wallet_Completed_Text = "Wallet.Completed.Text"
    case Wallet_Completed_ViewWallet = "Wallet.Completed.ViewWallet"
    case Wallet_SetPasscode_Title = "Wallet.SetPasscode.Title"
    case Wallet_SetPasscode_Text = "Wallet.SetPasscode.Text"
    case Wallet_SetPasscode_Options = "Wallet.SetPasscode.Options"
    case Wallet_SetPasscode_FourDigitCode = "Wallet.SetPasscode.FourDigitCode"
    case Wallet_SetPasscode_SixDigitCode = "Wallet.SetPasscode.SixDigitCode"
    case Wallet_SetPasscode_PasscodesDoNotMatch = "Wallet.SetPasscode.PasscodesDoNotMatch"
    case Wallet_ConfirmPasscode_Title = "Wallet.ConfirmPasscode.Title"
    case Wallet_ConfirmPasscode_Text = "Wallet.ConfirmPasscode.Text"
    case Wallet_Biometric_Reason = "Wallet.Biometric.Reason"
    case Wallet_Biometric_NotAvailableTitle = "Wallet.Biometric.NotAvailableTitle"
    case Wallet_Biometric_NotAvailableText = "Wallet.Biometric.NotAvailableText"
    case Wallet_Biometric_FaceID_Title = "Wallet.Biometric.FaceID.Title"
    case Wallet_Biometric_FaceID_Text = "Wallet.Biometric.FaceID.Text"
    case Wallet_Biometric_FaceID_Enable = "Wallet.Biometric.FaceID.Enable"
    case Wallet_Biometric_FaceID_Skip = "Wallet.Biometric.FaceID.Skip"
    case Wallet_Biometric_TouchID_Title = "Wallet.Biometric.TouchID.Title"
    case Wallet_Biometric_TouchID_Text = "Wallet.Biometric.TouchID.Text"
    case Wallet_Biometric_TouchID_Enable = "Wallet.Biometric.TouchID.Enable"
    case Wallet_Biometric_TouchID_Skip = "Wallet.Biometric.TouchID.Skip"

    case Wallet_Alert_OK = "Wallet.Alert.OK"

    public var localized: String {
        // we can cache strings in a dictionary, if some keys are being reused many times and it's required.
        return NSLocalizedString(rawValue, comment: "")
    }

    public static func Wallet_WordCheck_ViewWords(wordIndices: [Int]) -> String {
        return fillValues(WStrings.Wallet_WordCheck_Text.localized, values: wordIndices.map({ i in
            return "\(i + 1)"
        }))
    }
    
    public static func Wallet_SetPasscode_Text(digits: Int) -> String {
        return fillValues(WStrings.Wallet_SetPasscode_Text.localized, values: ["\(digits)"])
    }
    public static func Wallet_ConfirmPasscode_Text(digits: Int) -> String {
        return fillValues(WStrings.Wallet_ConfirmPasscode_Text.localized, values: ["\(digits)"])
    }
}

fileprivate func fillValues(_ format: String, values: [String]) -> String {
    var result = format
    for (index, value) in values.enumerated() {
        result = result.replacingOccurrences(of: "%\(index + 1)$@", with: value)
    }
    return result
}
