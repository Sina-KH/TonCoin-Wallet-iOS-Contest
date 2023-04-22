//
//  ReceiveVC.swift
//  UIWalletHome
//
//  Created by Sina on 4/22/23.
//

import UIKit
import UIComponents
import WalletContext
import WalletCore

public class ReceiveVC: WViewController {
    
    // MARK: - Initializer
    let walletContext: WalletContext
    let walletInfo: WalletInfo
    public init(walletContext: WalletContext, walletInfo: WalletInfo) {
        self.walletContext = walletContext
        self.walletInfo = walletInfo
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Load and SetupView Functions
    public override func loadView() {
        super.loadView()
        setupViews()
    }

    private var yourWalletAddressLabel: UILabel!

    private func setupViews() {
        // The whole page can be a vertical stack view with spacing between items
        //  This way we can support all variety of the devices easily :)
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            stackView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16),
            stackView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8)
        ])

        // top info stack view
        let topInfoStackView = UIStackView()
        topInfoStackView.translatesAutoresizingMaskIntoConstraints = false
        topInfoStackView.axis = .vertical
        topInfoStackView.spacing = 12
        topInfoStackView.alignment = .center
        stackView.addArrangedSubview(topInfoStackView)
        // title
        let titleLabel = UILabel()
        titleLabel.font = .systemFont(ofSize: 28, weight: .semibold)
        titleLabel.text = WStrings.Wallet_Receive_Title.localized
        topInfoStackView.addArrangedSubview(titleLabel)
        // description
        let descriptionLabel = UILabel()
        descriptionLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        topInfoStackView.addArrangedSubview(descriptionLabel)
        
        // wallet qr code stack view
        
        
        // wallet address stack view
        let addressStackView = UIStackView()
        addressStackView.translatesAutoresizingMaskIntoConstraints = false
        addressStackView.axis = .vertical
        addressStackView.spacing = 6
        addressStackView.alignment = .center
        stackView.addArrangedSubview(addressStackView)
        // address label
        let addressLabel = UILabel()
        addressLabel.translatesAutoresizingMaskIntoConstraints = false
        addressLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        addressLabel.numberOfLines = 0
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .justified
        let attributedString = NSAttributedString(string: formatAddress(walletInfo.address),
            attributes: [
                NSAttributedString.Key.paragraphStyle: paragraphStyle,
                NSAttributedString.Key.baselineOffset: NSNumber(value: 0)
            ]
        )
        addressLabel.attributedText = attributedString
        addressStackView.addArrangedSubview(addressLabel)
        // `your wallet address` label
        yourWalletAddressLabel = UILabel()
        yourWalletAddressLabel.translatesAutoresizingMaskIntoConstraints = false
        yourWalletAddressLabel.font = .systemFont(ofSize: 17, weight: .regular)
        yourWalletAddressLabel.text = WStrings.Wallet_Receive_YourAddress.localized
        addressStackView.addArrangedSubview(yourWalletAddressLabel)
        addressStackView.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        addressStackView.isLayoutMarginsRelativeArrangement = true

        // bottom action
        let shareButton = WButton.setupInstance(.primary)
        shareButton.translatesAutoresizingMaskIntoConstraints = false
        shareButton.setTitle(WStrings.Wallet_Receive_ShareAddress.localized, for: .normal)
        shareButton.addTarget(self, action: #selector(sharePressed), for: .touchUpInside)
        stackView.addArrangedSubview(shareButton)
        
        updateTheme()
    }
    
    func updateTheme() {
        yourWalletAddressLabel.textColor = currentTheme.secondaryLabel
    }
    
    @objc func sharePressed() {
        // TODO::
    }
}
