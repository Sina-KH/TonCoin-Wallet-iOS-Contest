//
//  SettingsVC.swift
//  UIWalletHome
//
//  Created by Sina on 4/30/23.
//

import UIKit
import UIPasscode
import UIComponents
import WalletContext
import WalletCore
import SwiftSignalKit

enum CurrencyIDs: Int {
    case USD = 1
    case EUR = 2
    case RUB = 3
}

class SettingsVC: WViewController {
    
    // MARK: - Initializer
    let walletContext: WalletContext
    let walletInfo: WalletInfo
    let onCurrencyChangedDelegate: (Int) -> Void
    
    private lazy var settingsViewModel = SettingsVM(settingsVMDelegate: self)
    
    public init(walletContext: WalletContext, walletInfo: WalletInfo, onCurrencyChanged: @escaping (Int) -> Void) {
        self.walletContext = walletContext
        self.walletInfo = walletInfo
        self.onCurrencyChangedDelegate = onCurrencyChanged
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Load and SetupView Functions
    private var scrollView: UIScrollView!
    private var stackView: UIStackView!
    private var notificationsSwitch: UISwitch!
    private var biometricSwitch: UISwitch!
    private var addressPicker: PickerView!
    private var currencyPicker: PickerView!
    
    override func loadView() {
        super.loadView()
        view.backgroundColor = WTheme.groupedBackground
        navigationItem.title = WStrings.Wallet_Settings_Title.localized

        // add done button if it's root of a navigation controller
        if navigationController?.viewControllers.count == 1 {
            let doneButton = UIBarButtonItem(title: WStrings.Wallet_Navigation_Done.localized, style: .done, target: self, action: #selector(donePressed))
            navigationItem.rightBarButtonItem = doneButton
        }

        // parent scrollView
        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            // scrollView
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leftAnchor.constraint(equalTo: view.leftAnchor),
            scrollView.rightAnchor.constraint(equalTo: view.rightAnchor),
            // contentLayout
            scrollView.contentLayoutGuide.widthAnchor.constraint(equalTo: view.widthAnchor),
        ])

        // content stack view
        stackView = UIStackView()
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 0),
            stackView.leftAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.leftAnchor, constant: 16),
            stackView.rightAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.rightAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: 0)
        ])

        // `GENERAL` title
        addSettingsHeader(title: WStrings.Wallet_Settings_General.localized)
        // notifications
        notificationsSwitch = addSwitchItem(position: .top,
                      title: WStrings.Wallet_Settings_Notifications.localized,
                      switchSelector: #selector(notificationsPressed))
        // active address
        addressPicker = addPickerItem(position: .middle,
                                      title: WStrings.Wallet_Settings_ActiveAddress.localized,
                                      items: [
                                        PickerViewItem(id: -1, name: "Original App (v3R2)"), // uses subwallet id: 4085333890
                                        PickerViewItem(id: 31, name: "v3R1"),
                                        PickerViewItem(id: 32, name: "v3R2"),
                                        PickerViewItem(id: 42, name: "v4R2")
                                      ],
                                      selectedID: walletInfo.version,
                                      selector: #selector(addressSelected),
                                      onChangeSelector: #selector(onAddressChanged))
        // primary currency
        currencyPicker = addPickerItem(position: .bottom,
                                       title: WStrings.Wallet_Settings_PrimaryCurrency.localized,
                                       items: [
                                        PickerViewItem(id: 1, name: WStrings.Wallet_Settings_CurrencyUSD.localized),
                                        PickerViewItem(id: 2, name: WStrings.Wallet_Settings_CurrencyEUR.localized),
                                        PickerViewItem(id: 3, name: WStrings.Wallet_Settings_CurrencyRUB.localized)
                                       ],
                                       selectedID: UserDefaultsHelper.selectedCurrencyID(),
                                       selector: #selector(currencySelected),
                                       onChangeSelector: #selector(onCurrencyChanged))

        // `SECURITY` title
        addSettingsHeader(title: WStrings.Wallet_Settings_Security.localized)
        // show recovery phrase
        addNavigationItem(position: .top,
                          title: WStrings.Wallet_Settings_ShowRecoveryPhrase.localized,
                          selector: #selector(recoveryPhrasePressed))
        // change passcode
        addNavigationItem(position: .middle,
                          title: WStrings.Wallet_Settings_ChangePasscode.localized,
                          selector: #selector(changePasscodePressed))
        // faceID / touchID
        let biometricString: String?
        switch BiometricHelper.biometricType() {
        case .face:
            biometricString = WStrings.Wallet_Settings_FaceID.localized
            break
        case .touch:
            biometricString = WStrings.Wallet_Settings_TouchID.localized
            break
        case .none:
            biometricString = nil
            break
        }
        if let biometricString = biometricString {
            biometricSwitch = addSwitchItem(position: .bottom,
                          title: biometricString,
                          switchSelector: #selector(biometricActiavationPressed))
            biometricSwitch.isOn = settingsViewModel.isBiometricActivated
        }

        // Delete Wallet
        stackView.setCustomSpacing(16,
                                   after: stackView.arrangedSubviews[stackView.arrangedSubviews.count - 1])
        let deleteWalletButton = WBaseButton(type: .system)
        deleteWalletButton.translatesAutoresizingMaskIntoConstraints = false
        deleteWalletButton.backgroundColor = WTheme.background
        deleteWalletButton.highlightBackgroundColor = WTheme.backgroundReverse.withAlphaComponent(0.1)
        deleteWalletButton.addTarget(self, action: #selector(deleteWallet), for: .touchUpInside)
        deleteWalletButton.layer.cornerRadius = 10
        deleteWalletButton.tintColor = WTheme.error
        deleteWalletButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        deleteWalletButton.setTitle(WStrings.Wallet_Settings_DeleteWallet.localized, for: .normal)
        deleteWalletButton.contentHorizontalAlignment = .leading
        deleteWalletButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        stackView.addArrangedSubview(deleteWalletButton)
        NSLayoutConstraint.activate([
            deleteWalletButton.leftAnchor.constraint(equalTo: stackView.leftAnchor),
            deleteWalletButton.rightAnchor.constraint(equalTo: stackView.rightAnchor),
            deleteWalletButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    // add a title label to stack view
    private func addSettingsHeader(title: String) {
        if stackView.arrangedSubviews.count > 0 {
            stackView.setCustomSpacing(22, after: stackView.arrangedSubviews[stackView.arrangedSubviews.count - 1])
        }
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = title
        label.textColor = WTheme.secondaryLabel
        label.font = .systemFont(ofSize: 13, weight: .regular)
        stackView.addArrangedSubview(label)
        NSLayoutConstraint.activate([
            label.leftAnchor.constraint(equalTo: stackView.leftAnchor, constant: 16),
            label.rightAnchor.constraint(equalTo: stackView.rightAnchor, constant: -16)
        ])
        stackView.setCustomSpacing(4, after: label)
    }
    
    // adds a switch item to the settings
    private func addSwitchItem(position: ItemPosition, title: String, switchSelector: Selector) -> UISwitch {
        let switchView = UISwitch()
        switchView.translatesAutoresizingMaskIntoConstraints = false
        switchView.addTarget(self, action: switchSelector, for: .valueChanged)
        addItem(position: position, title: title, rightView: switchView, selector: switchSelector)
        return switchView
    }
    
    // add multi select item to the settings
    private func addPickerItem(position: ItemPosition,
                               title: String,
                               items: [PickerViewItem],
                               selectedID: Int,
                               selector: Selector,
                               onChangeSelector: Selector) -> PickerView {
        let pickerView = PickerView(items: items, selectedID: selectedID, onChange: { _ in
            self.perform(onChangeSelector)
        })
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        addItem(position: position, title: title, rightView: pickerView, selector: selector)
        return pickerView
    }
    
    // add navigation item to the settings
    private func addNavigationItem(position: ItemPosition, title: String, selector: Selector) {
        let rightArrowImageView = UIImageView(image: UIImage(named: "RightArrowIcon")!.withRenderingMode(.alwaysTemplate))
        rightArrowImageView.tintColor = WTheme.secondaryLabel
        rightArrowImageView.translatesAutoresizingMaskIntoConstraints = false
        rightArrowImageView.contentMode = .center
        addItem(position: position, title: title, rightView: rightArrowImageView, selector: selector)
    }

    // adds an item to settings items
    private enum ItemPosition {
        case top
        case middle
        case bottom
    }
    private func addItem(position: ItemPosition, title: String, rightView: UIView, selector: Selector) {
        let settingsItemView = WHighlightView()
        settingsItemView.highlightBackgroundColor = WTheme.backgroundReverse.withAlphaComponent(0.1)
        settingsItemView.backgroundColor = WTheme.background
        settingsItemView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(settingsItemView)
        NSLayoutConstraint.activate([
            settingsItemView.heightAnchor.constraint(equalToConstant: 44),
            settingsItemView.leftAnchor.constraint(equalTo: stackView.leftAnchor),
            settingsItemView.rightAnchor.constraint(equalTo: stackView.rightAnchor)
        ])
        if position != .middle {
            settingsItemView.layer.cornerRadius = 10
            if position == .top {
                settingsItemView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            } else {
                settingsItemView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            }
        }

        // title
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 17, weight: .regular)
        titleLabel.text = title
        settingsItemView.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.centerYAnchor.constraint(equalTo: settingsItemView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: settingsItemView.leadingAnchor, constant: 16)
        ])

        // right view
        settingsItemView.addSubview(rightView)
        NSLayoutConstraint.activate([
            rightView.centerYAnchor.constraint(equalTo: settingsItemView.centerYAnchor),
            rightView.trailingAnchor.constraint(equalTo: settingsItemView.trailingAnchor, constant: -16)
        ])

        // separator
        if position != .bottom {
            let separatorView = UIView()
            separatorView.translatesAutoresizingMaskIntoConstraints = false
            separatorView.backgroundColor = WTheme.separator
            settingsItemView.addSubview(separatorView)
            NSLayoutConstraint.activate([
                separatorView.heightAnchor.constraint(equalToConstant: 0.33),
                separatorView.leadingAnchor.constraint(equalTo: settingsItemView.leadingAnchor, constant: 16),
                separatorView.trailingAnchor.constraint(equalTo: settingsItemView.trailingAnchor),
                separatorView.bottomAnchor.constraint(equalTo: settingsItemView.bottomAnchor)
            ])
        }
        
        settingsItemView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: selector))
    }

    // MARK: - Actions
    @objc func notificationsPressed(sender: AnyObject) {
        if (sender as? UISwitch) != notificationsSwitch {
            notificationsSwitch.setOn(!notificationsSwitch.isOn, animated: true)
        }
    }
    
    private var activatingBiometricInProgress = false
    @objc func biometricActiavationPressed(sender: AnyObject) {
        if activatingBiometricInProgress {
            return
        }
        if (sender as? UISwitch) != biometricSwitch {
            biometricSwitch.setOn(!biometricSwitch.isOn, animated: true)
        }
        if biometricSwitch.isOn {
            activatingBiometricInProgress = true
            biometricSwitch.isUserInteractionEnabled = false
            settingsViewModel.activateBiometric()
        } else {
            settingsViewModel.disableBiometric()
        }
    }
    
    @objc func donePressed() {
        dismiss(animated: true)
    }
    
    @objc func recoveryPhrasePressed() {
        settingsViewModel.loadRecoveryPhrase(walletContext: walletContext, walletInfo: walletInfo)
    }
    
    @objc func changePasscodePressed() {
        let nav = UINavigationController(rootViewController: ChangePasscodeVC(step: .currentPasscode))
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }
    
    @objc func addressSelected(sender: Any) {
        addressPicker.pickerPressed()
    }
    @objc func onAddressChanged() {
        let walletVersion = addressPicker.selectedID
        let _ = (setWalletVersion(to: walletVersion,
                                 tonInstance: walletContext.tonInstance,
                                 walletInfo: walletInfo,
                                 storage: walletContext.storage)
        |> deliverOnMainQueue).start(error: { _ in
            
        }, completed: { [weak self] in
            KeychainHelper.save(walletVersion: walletVersion)
            guard let self else {
                return
            }
            DispatchQueue.main.async {
                self.walletContext.restartApp()
            }
        })
    }
    
    @objc func currencySelected(sender: Any) {
        currencyPicker.pickerPressed()
    }
    @objc func onCurrencyChanged() {
        UserDefaultsHelper.select(currencyID: currencyPicker.selectedID)
        onCurrencyChangedDelegate(currencyPicker.selectedID)
    }
    
    @objc func deleteWallet() {
        showAlert(title: nil,
                  text: WStrings.Wallet_Settings_DeleteWalletInfo.localized,
                  button: WStrings.Wallet_Settings_DeleteWallet.localized,
                  buttonStyle: .destructive,
                  buttonPressed: { [weak self] in
            guard let self else {
                return
            }
            let _ = (deleteAllLocalWalletsData(storage: walletContext.storage,
                                               tonInstance: walletContext.tonInstance)
            |> deliverOnMainQueue).start(error: { _ in
                
            }, completed: { [weak self] in
                KeychainHelper.deleteWallet()
                guard let self else {
                    return
                }
                DispatchQueue.main.async {
                    self.walletContext.restartApp()
                }
            })
        }, secondaryButton: WStrings.Wallet_Navigation_Cancel.localized)
    }
}

extension SettingsVC: SettingsVMDelegate {
    func showRecoveryPhrase(wordList: [String]) {
        navigationController?.pushViewController(RecoveryPhraseVC(walletContext: walletContext,
                                                                  walletInfo: walletInfo,
                                                                  wordList: wordList), animated: true)
    }

    func biometricUpdated(to: Bool) {
        activatingBiometricInProgress = false
        biometricSwitch.isUserInteractionEnabled = true
        biometricSwitch.setOn(to, animated: true)
    }
    
    func biometricActivationErrorOccured() {
        activatingBiometricInProgress = false
        biometricSwitch.isUserInteractionEnabled = true
        showAlert(title: WStrings.Wallet_Biometric_NotAvailableTitle.localized,
                  text: WStrings.Wallet_Biometric_NotAvailableText.localized,
                  button: WStrings.Wallet_Alert_OK.localized)
        biometricSwitch.setOn(settingsViewModel.isBiometricActivated, animated: true)
    }
}
