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
    case Wallet_WordImport_Title = "Wallet.WordImport.Title"
    case Wallet_WordImport_Text = "Wallet.WordImport.Text"
    case Wallet_WordImport_Continue = "Wallet.WordImport.Continue"
    case Wallet_WordImport_CanNotRemember = "Wallet.WordImport.CanNotRemember"
    case Wallet_WordImport_IncorrectTitle = "Wallet.WordImport.IncorrectTitle"
    case Wallet_WordImport_IncorrectText = "Wallet.WordImport.IncorrectText"
    case Wallet_ImportSuccessful_Title = "Wallet.ImportSuccessful.Title"
    case Wallet_RestoreFailed_Title = "Wallet.RestoreFailed.Title"
    case Wallet_RestoreFailed_Text = "Wallet.RestoreFailed.Text"
    case Wallet_RestoreFailed_EnterWords = "Wallet.RestoreFailed.EnterWords"
    case Wallet_RestoreFailed_CreateWallet = "Wallet.RestoreFailed.CreateWallet"
    case Wallet_SecuritySettingsChanged_Title = "Wallet.SecuritySettingsChanged.Title"
    case Wallet_SecuritySettingsChanged_BiometryTouchID = "Wallet.SecuritySettingsChanged.BiometryTouchID"
    case Wallet_SecuritySettingsChanged_BiometryFaceID = "Wallet.SecuritySettingsChanged.BiometryFaceID"
    case Wallet_SecuritySettingsChanged_ResetBiometryText = "Wallet.SecuritySettingsChanged.ResetBiometryText"
    case Wallet_SecuritySettingsChanged_ResetPasscodeText = "Wallet.SecuritySettingsChanged.ResetPasscodeText"
    case Wallet_SecuritySettingsChanged_BiometryText = "Wallet.SecuritySettingsChanged.BiometryText"
    case Wallet_SecuritySettingsChanged_PasscodeText = "Wallet.SecuritySettingsChanged.PasscodeText"
    case Wallet_SecuritySettingsChanged_ImportWallet = "Wallet.SecuritySettingsChanged.ImportWallet"
    case Wallet_SecuritySettingsChanged_CreateWallet = "Wallet.SecuritySettingsChanged.CreateWallet"
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
    case Wallet_Home_Receive = "Wallet.Home.Receive"
    case Wallet_Home_Send = "Wallet.Home.Send"
    case Wallet_Home_RefreshErrorTitle = "Wallet.Home.RefreshErrorTitle"
    case Wallet_Home_RefreshErrorText = "Wallet.Home.RefreshErrorText"
    case Wallet_Home_RefreshErrorNetworkText = "Wallet.Home.RefreshErrorNetworkText"
    case Wallet_Home_WalletCreated = "Wallet.Home.WalletCreated"
    case Wallet_Home_Address = "Wallet.Home.Address"
    case Wallet_Home_TransactionTo = "Wallet.Home.TransactionTo"
    case Wallet_Home_TransactionFrom = "Wallet.Home.TransactionFrom"
    case Wallet_Home_WaitingForNetwork = "Wallet.Home.WaitingForNetwork"
    case Wallet_Home_Connecting = "Wallet.Home.Connecting"
    case Wallet_Home_Updating = "Wallet.Home.Updating"
    case Wallet_Home_TransactionStorageFee = "Wallet.Home.TransactionStorageFee"
    case Wallet_Home_TransactionPendingHeader = "Wallet.Home.TransactionPendingHeader"
    case Wallet_Home_InitTransaction = "Wallet.Home.InitTransaction"
    case Wallet_Home_UnknownTransaction = "Wallet.Home.UnknownTransaction"
    case Wallet_TransactionInfo_Title = "Wallet.TransactionInfo.Title"
    case Wallet_TransactionInfo_OtherFee = "Wallet.TransactionInfo.OtherFee"
    case Wallet_TransactionInfo_Details = "Wallet.TransactionInfo.Details"
    case Wallet_TransactionInfo_SenderAddress = "Wallet.TransactionInfo.SenderAddress"
    case Wallet_TransactionInfo_Recipient = "Wallet.TransactionInfo.Recipient"
    case Wallet_TransactionInfo_RecipientAddress = "Wallet.TransactionInfo.RecipientAddress"
    case Wallet_TransactionInfo_Transaction = "Wallet.TransactionInfo.Transaction"
    case Wallet_TransactionInfo_ViewInExplorer = "Wallet.TransactionInfo.ViewInExplorer"
    case Wallet_TransactionInfo_SendTONToThisAddress = "Wallet.TransactionInfo.SendTONToThisAddress"
    case Wallet_TransactionInfo_RetryTransaction = "Wallet.TransactionInfo.RetryTransaction"
    case Wallet_TransactionInfo_Pending = "Wallet.TransactionInfo.Pending"
    case Wallet_Receive_Title = "Wallet.Receive.Title"
    case Wallet_Receive_Description = "Wallet.Receive.Description"
    case Wallet_Receive_Toncoin = "Wallet.Receive.Toncoin"
    case Wallet_Receive_YourAddress = "Wallet.Receive.YourAddress"
    case Wallet_Receive_ShareAddress = "Wallet.Receive.ShareAddress"
    case Wallet_Send_Title = "Wallet.Send.Title"
    case Wallet_Send_AddressText = "Wallet.Send.AddressText"
    case Wallet_Send_AddressInfo = "Wallet.Send.AddressInfo"
    case Wallet_Send_Paste = "Wallet.Send.Paste"
    case Wallet_Send_Scan = "Wallet.Send.Scan"
    case Wallet_Send_Continue = "Wallet.Send.Continue"
    case Wallet_Send_Recents = "Wallet.Send.Recents"
    case Wallet_Send_Clear = "Wallet.Send.Clear"
    case Wallet_Send_ErrorInvalidAddressTitle = "Wallet.Send.ErrorInvalidAddressTitle"
    case Wallet_Send_ErrorInvalidAddressText = "Wallet.Send.ErrorInvalidAddressText"
    case Wallet_SendAmount_SendTo = "Wallet.SendAmount.SendTo"
    case Wallet_SendAmount_SendAll = "Wallet.SendAmount.SendAll"
    case Wallet_SendAmount_Edit = "Wallet.SendAmount.Edit"
    case Wallet_SendAmount_Continue = "Wallet.SendAmount.Continue"
    case Wallet_SendAmount_NotEnoughFunds = "Wallet.SendAmount.NotEnoughFunds"
    case Wallet_SendConfirm_Comment = "Wallet.SendConfirm.Comment"
    case Wallet_SendConfirm_CommentPlaceholder = "Wallet.SendConfirm.CommentPlaceholder"
    case Wallet_SendConfirm_Hint = "Wallet.SendConfirm.Hint"
    case Wallet_SendConfirm_HintMessageSizeExceeded = "Wallet.SendConfirm.HintMessageSizeExceeded"
    case Wallet_SendConfirm_HintMessageCharactersLeft = "Wallet.SendConfirm.HintMessageCharactersLeft"
    case Wallet_SendConfirm_Label = "Wallet.SendConfirm.Label"
    case Wallet_SendConfirm_Recipient = "Wallet.SendConfirm.Recipient"
    case Wallet_SendConfirm_Amount = "Wallet.SendConfirm.Amount"
    case Wallet_SendConfirm_Fee = "Wallet.SendConfirm.Fee"
    case Wallet_SendConfirm_ConfirmAndSend = "Wallet.SendConfirm.ConfirmAndSend"
    case Wallet_SendConfirm_NetworkErrorTitle = "Wallet.SendConfirm.NetworkErrorTitle"
    case Wallet_SendConfirm_NetworkErrorText = "Wallet.SendConfirm.NetworkErrorText"
    case Wallet_SendConfirm_ErrorDecryptionFailed = "Wallet.SendConfirm.ErrorDecryptionFailed"
    case Wallet_SendConfirm_ErrorNotEnoughFundsTitle = "Wallet.SendConfirm.ErrorNotEnoughFundsTitle"
    case Wallet_SendConfirm_ErrorNotEnoughFundsText = "Wallet.SendConfirm.ErrorNotEnoughFundsText"
    case Wallet_SendConfirm_ErrorInvalidAddress = "Wallet.SendConfirm.ErrorInvalidAddress"
    case Wallet_SendConfirm_UnknownError = "Wallet.SendConfirm.UnknownError"
    case Wallet_SendConfirm_Confirmation = "Wallet.SendConfirm.Confirmation"
    case Wallet_SendConfirm_ConfirmationText = "Wallet.SendConfirm.ConfirmationText"
    case Wallet_SendConfirm_CommentNotEncrypted = "Wallet.SendConfirm.CommentNotEncrypted"
    case Wallet_SendConfirm_ConfirmationConfirm = "Wallet.SendConfirm.ConfirmationConfirm"
    case Wallet_Sending_Title = "Wallet.Sending.Title"
    case Wallet_Sending_Text = "Wallet.Sending.Text"
    case Wallet_Sending_UninitializedTitle = "Wallet.Sending.UninitializedTitle"
    case Wallet_Sending_UninitializedText = "Wallet.Sending.UninitializedText"
    case Wallet_Sending_SendAnyway = "Wallet.Sending.SendAnyway"
    case Wallet_Sending_ViewWallet = "Wallet.Sending.ViewWallet"
    case Wallet_Sent_Title = "Wallet.Sent.Title"
    case Wallet_Sent_Text = "Wallet.Sent.Text"
    case Wallet_Sent_ViewWallet = "Wallet.Sent.ViewWallet"
    case Wallet_Settings_Title = "Wallet.Settings.Title"
    case Wallet_Settings_General = "Wallet.Settings.General"
    case Wallet_Settings_Notifications = "Wallet.Settings.Notifications"
    case Wallet_Settings_ActiveAddress = "Wallet.Settings.ActiveAddress"
    case Wallet_Settings_PrimaryCurrency = "Wallet.Settings.PrimaryCurrency"
    case Wallet_Settings_Security = "Wallet.Settings.Security"
    case Wallet_Settings_ShowRecoveryPhrase = "Wallet.Settings.ShowRecoveryPhrase"
    case Wallet_Settings_ChangePasscode = "Wallet.Settings.ChangePasscode"
    case Wallet_Settings_TouchID = "Wallet.Settings.TouchID"
    case Wallet_Settings_FaceID = "Wallet.Settings.FaceID"
    case Wallet_Settings_DeleteWallet = "Wallet.Settings.DeleteWallet"
    case Wallet_Settings_DeleteWalletInfo = "Wallet.Settings.DeleteWalletInfo"
    case Wallet_Settings_CurrencyUSD = "Wallet.Settings.CurrencyUSD"
    case Wallet_Settings_CurrencyEUR = "Wallet.Settings.CurrencyEUR"
    case Wallet_Settings_CurrencyRUB = "Wallet.Settings.CurrencyRUB"
    case Wallet_Unlock_Title = "Wallet.Unlock.Title"
    case Wallet_ChangePasscode_Title = "Wallet.ChangePasscode.Title"
    case Wallet_ChangePasscode_NewPassTitle = "Wallet.ChangePasscode.NewPassTitle"
    case Wallet_ChangePasscode_NewPassVerifyTitle = "Wallet.ChangePasscode.NewPassVerifyTitle"
    case Wallet_TonConnect_ConnectTo = "Wallet.TonConnect.ConnectTo"
    case Wallet_TonConnect_RequestText = "Wallet.TonConnect.RequestText"
    case Wallet_TonConnect_Notice = "Wallet.TonConnect.Notice"
    case Wallet_TonConnect_ConnectWallet = "Wallet.TonConnect.ConnectWallet"
    case Wallet_TonConnectTransfer_Title = "Wallet.TonConnectTransfer.Title"
    case Wallet_TonConnectTransfer_Recipient = "Wallet.TonConnectTransfer.Recipient"
    case Wallet_TonConnectTransfer_Fee = "Wallet.TonConnectTransfer.Fee"
    case Wallet_TonConnectTransfer_Confirm = "Wallet.TonConnectTransfer.Confirm"
    case Wallet_TonConnectTransfer_Cancel = "Wallet.TonConnectTransfer.Cancel"
    case Wallet_QRScan_Title = "Wallet.QRScan.Title"
    case Wallet_QRScan_NoAccessTitle = "Wallet.QRScan.NoAccessTitle"
    case Wallet_QRScan_NoAccessCamera = "Wallet.QRScan.NoAccessCamera"
    case Wallet_QRScan_NoAccessOpenSettings = "Wallet.QRScan.NoAccessOpenSettings"
    case Wallet_QRScan_NoValidQRDetected = "Wallet.QRScan.NoValidQRDetected"
    case Wallet_Navigation_Back = "Wallet.Navigation.Back"
    case Wallet_Navigation_Done = "Wallet.Navigation.Done"
    case Wallet_Navigation_Cancel = "Wallet.Navigation.Cancel"
    case Wallet_Alert_OK = "Wallet.Alert.OK"
    case Wallet_Time_PreciseDate_m1 = "Wallet.Time.PreciseDate_m1"
    case Wallet_Time_PreciseDate_m2 = "Wallet.Time.PreciseDate_m2"
    case Wallet_Time_PreciseDate_m3 = "Wallet.Time.PreciseDate_m3"
    case Wallet_Time_PreciseDate_m4 = "Wallet.Time.PreciseDate_m4"
    case Wallet_Time_PreciseDate_m5 = "Wallet.Time.PreciseDate_m5"
    case Wallet_Time_PreciseDate_m6 = "Wallet.Time.PreciseDate_m6"
    case Wallet_Time_PreciseDate_m7 = "Wallet.Time.PreciseDate_m7"
    case Wallet_Time_PreciseDate_m8 = "Wallet.Time.PreciseDate_m8"
    case Wallet_Time_PreciseDate_m9 = "Wallet.Time.PreciseDate_m9"
    case Wallet_Time_PreciseDate_m10 = "Wallet.Time.PreciseDate_m10"
    case Wallet_Time_PreciseDate_m11 = "Wallet.Time.PreciseDate_m11"
    case Wallet_Time_PreciseDate_m12 = "Wallet.Time.PreciseDate_m12"

    public var localized: String {
        // we can cache strings in a dictionary, if some keys are being reused many times and it's required.
        return NSLocalizedString(rawValue, comment: "")
    }

    public static func Wallet_WordCheck_ViewWords(wordIndices: [Int]) -> String {
        return fillValues(WStrings.Wallet_WordCheck_Text.localized, values: wordIndices.map({ i in
            return "\(i + 1)"
        }))
    }
    
    public static func Wallet_SecuritySettingsChanged_ResetBiometryText(biometricType: String) -> String {
        return fillValues(WStrings.Wallet_SecuritySettingsChanged_ResetBiometryText.localized, values: [biometricType])
    }
    
    public static func Wallet_SecuritySettingsChanged_BiometryText(biometricType: String) -> String {
        return fillValues(WStrings.Wallet_SecuritySettingsChanged_BiometryText.localized, values: [biometricType])
    }

    public static func Wallet_SetPasscode_Text(digits: Int) -> String {
        return fillValues(WStrings.Wallet_SetPasscode_Text.localized, values: ["\(digits)"])
    }
    public static func Wallet_ConfirmPasscode_Text(digits: Int) -> String {
        return fillValues(WStrings.Wallet_ConfirmPasscode_Text.localized, values: ["\(digits)"])
    }
    
    public static func Wallet_Home_TransactionStorageFee(storageFee: String) -> String {
        return fillValues(WStrings.Wallet_Home_TransactionStorageFee.localized, values: [storageFee])
    }
    
    public static func Wallet_TransactionInfo_OtherFee(otherFee: String) -> String {
        return fillValues(WStrings.Wallet_TransactionInfo_OtherFee.localized, values: [otherFee])
    }
    
    public static func Wallet_Receive_Description(coin: String) -> String {
        return fillValues(WStrings.Wallet_Receive_Description.localized, values: [coin])
    }
    
    public static func Wallet_SendConfirm_HintMessageSizeExceeded(chars: Int) -> String {
        return fillValues(WStrings.Wallet_SendConfirm_HintMessageSizeExceeded.localized, values: ["\(chars)"])
    }
    
    public static func Wallet_SendConfirm_HintMessageCharactersLeft(chars: Int) -> String {
        return fillValues(WStrings.Wallet_SendConfirm_HintMessageCharactersLeft.localized, values: ["\(chars)"])
    }
    
    public static func Wallet_SendConfirm_ConfirmationText(textAttr: [NSAttributedString.Key: Any],
                                                           address: NSAttributedString,
                                                           amount: NSAttributedString,
                                                           fee: NSAttributedString) -> NSMutableAttributedString {
        return fillValues(WStrings.Wallet_SendConfirm_ConfirmationText.localized,
                          textAttr: textAttr,
                          values: [amount, address, fee])
    }
    
    public static func Wallet_Sent_Text(amount: String) -> String {
        return fillValues(WStrings.Wallet_Sent_Text.localized, values: [amount])
    }
    
    public static func Wallet_TonConnect_ConnectTo(app: String) -> String {
        return fillValues(WStrings.Wallet_TonConnect_ConnectTo.localized, values: [app])
    }
    
    public static func Wallet_TonConnect_RequestText(textAttr: [NSAttributedString.Key: Any],
                                                     application: NSAttributedString,
                                                     address: NSAttributedString,
                                                     walletVersion: NSAttributedString) -> NSMutableAttributedString {
        return fillValues(WStrings.Wallet_TonConnect_RequestText.localized,
                          textAttr: textAttr,
                          values: [application, address, walletVersion])
    }

    public static func fillValues(_ format: String, values: [String]) -> String {
        var result = format
        for (index, value) in values.enumerated() {
            result = result.replacingOccurrences(of: "%\(index + 1)$@", with: value)
        }
        return result
    }

    private static func fillValues(_ format: String,
                                   textAttr: [NSAttributedString.Key: Any],
                                   values: [NSAttributedString]) -> NSMutableAttributedString {
        var formatString = format
        let result = NSMutableAttributedString()
        for (index, value) in values.enumerated() {
            if let valueRange = formatString.range(of: "%\(index + 1)$@") {
                // the string before format value
                let stringBeforeValue = String(formatString[..<valueRange.lowerBound])
                formatString = String(formatString[valueRange.upperBound...])
                result.append(NSAttributedString(string: String(stringBeforeValue)))
                // value
                result.append(value)
            }
        }
        return result
    }

}
