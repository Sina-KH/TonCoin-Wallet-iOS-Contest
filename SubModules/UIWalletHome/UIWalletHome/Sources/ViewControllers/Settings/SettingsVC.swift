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

class SettingsVC: WViewController {
    
    // MARK: - Initializer
    let walletContext: WalletContext
    let walletInfo: WalletInfo
    let walletHomeVC: WalletHomeVC
    public init(walletContext: WalletContext, walletInfo: WalletInfo, walletHomeVC: WalletHomeVC) {
        self.walletContext = walletContext
        self.walletInfo = walletInfo
        self.walletHomeVC = walletHomeVC
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Load and SetupView Functions
    private var scrollView: UIScrollView!
    private var stackView: UIStackView!

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
        addSwitchItem(position: .top,
                      title: WStrings.Wallet_Settings_Notifications.localized,
                      switchSelector: #selector(notificationsChanged))
        // active address
        addMultiSelectItem(position: .middle,
                           title: WStrings.Wallet_Settings_ActiveAddress.localized,
                           items: [
                            MultiSelectItem(id: 31, name: "v3R1"),
                            MultiSelectItem(id: 32, name: "v4R1"),
                            MultiSelectItem(id: 42, name: "v4R2")
                           ], selectedID: 32)
        // primary currency
        addMultiSelectItem(position: .bottom,
                           title: WStrings.Wallet_Settings_PrimaryCurrency.localized,
                           items: [
                            MultiSelectItem(id: 1, name: WStrings.Wallet_Settings_CurrencyUSD.localized),
                            MultiSelectItem(id: 1, name: WStrings.Wallet_Settings_CurrencyEUR.localized)
                           ], selectedID: 1)

        // `SECURITY` title
        addSettingsHeader(title: WStrings.Wallet_Settings_Security.localized)
        // show recovery phrase
        addNavigationItem(position: .top,
                          title: WStrings.Wallet_Settings_ShowRecoveryPhrase.localized) {
            // TODO::
        }
        // change passcode
        addNavigationItem(position: .middle,
                          title: WStrings.Wallet_Settings_ChangePasscode.localized) {
            // TODO::
        }
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
            addSwitchItem(position: .bottom,
                          title: biometricString,
                          switchSelector: #selector(biometricActiavationChanged))
        }

        // Delete Wallet
        stackView.setCustomSpacing(16,
                                   after: stackView.arrangedSubviews[stackView.arrangedSubviews.count - 1])
        let deleteWalletButton = WBaseButton(type: .system)
        deleteWalletButton.translatesAutoresizingMaskIntoConstraints = false
        deleteWalletButton.backgroundColor = WTheme.background
        deleteWalletButton.highlightBackgroundColor = WTheme.background.withAlphaComponent(0.4)
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
    private func addSwitchItem(position: ItemPosition, title: String, switchSelector: Selector) {
        let switchView = UISwitch()
        switchView.translatesAutoresizingMaskIntoConstraints = false
        switchView.addTarget(self, action: switchSelector, for: .valueChanged)
        addItem(position: position, title: title, rightView: switchView)
    }
    
    // add multi select item to the settings
    private func addMultiSelectItem(position: ItemPosition, title: String, items: [MultiSelectItem], selectedID: Int) {
        let multiSelectView = MultiSelectView(items: items, selectedID: selectedID)
        addItem(position: position, title: title, rightView: multiSelectView)
    }
    
    // add navigation item to the settings
    private func addNavigationItem(position: ItemPosition, title: String, onSelect: () -> Void) {
        let rightArrowImageView = UIImageView(image: UIImage(named: "RightArrowIcon")!.withRenderingMode(.alwaysTemplate))
        rightArrowImageView.tintColor = WTheme.secondaryLabel
        rightArrowImageView.translatesAutoresizingMaskIntoConstraints = false
        rightArrowImageView.contentMode = .center
        addItem(position: position,
                title: title,
                rightView: rightArrowImageView)
    }

    // adds an item to settings items
    private enum ItemPosition {
        case top
        case middle
        case bottom
    }
    private func addItem(position: ItemPosition, title: String, rightView: UIView) {
        let settingsItemView = UIView()
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
    }

    @objc func notificationsChanged(sender: UISwitch) {
        print(sender.isOn)
    }
    
    @objc func biometricActiavationChanged(sender: UISwitch) {
        print(sender.isOn)
    }
    
    @objc func donePressed() {
        dismiss(animated: true)
    }
    
    @objc func deleteWallet() {
        showAlert(title: nil,
                  text: WStrings.Wallet_Settings_DeleteWalletInfo.localized,
                  button: WStrings.Wallet_Settings_DeleteWallet.localized) { [weak self] in
            guard let self else {
                return
            }
            let _ = (deleteAllLocalWalletsData(storage: walletContext.storage,
                                               tonInstance: walletContext.tonInstance)
            |> deliverOnMainQueue).start(error: { [weak self] _ in
                
            }, completed: { [weak self] in
                guard let self else {
                    return
                }
                DispatchQueue.main.async {
                    self.walletContext.restartApp()
                }
            })
        }
    }
}
