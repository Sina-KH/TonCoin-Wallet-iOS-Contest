//
//  SentVC.swift
//  UIWalletSend
//
//  Created by Sina on 4/28/23.
//

import UIKit
import UIComponents
import WalletContext

public class SentVC: WViewController {
    
    // MARK: - Initializer
    private let address: String
    private let amount: Int64
    public init(address: String, amount: Int64) {
        self.address = address
        self.amount = amount
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func loadView() {
        super.loadView()
        setupViews()
    }

    private func setupViews() {
        navigationItem.hidesBackButton = true

        // view my wallet button
        let viewWalletButton = WButton.setupInstance(.primary)
        viewWalletButton.translatesAutoresizingMaskIntoConstraints = false
        viewWalletButton.setTitle(WStrings.Wallet_Sent_ViewWallet.localized, for: .normal)
        viewWalletButton.addTarget(self, action: #selector(viewWalletPressed), for: .touchUpInside)
        view.addSubview(viewWalletButton)
        NSLayoutConstraint.activate([
            viewWalletButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -58),
            viewWalletButton.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 48),
            viewWalletButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -48),
        ])

        // top view
        let topView = UIView()
        topView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(topView)
        NSLayoutConstraint.activate([
            topView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            topView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            topView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            topView.bottomAnchor.constraint(equalTo: viewWalletButton.topAnchor)
        ])

        // header, center of top view
        let headerView = HeaderView(animationName: "Success",
                                    animationPlaybackMode: .loop,
                                    title: WStrings.Wallet_Sent_Title.localized,
                                    description: WStrings.Wallet_Sent_Text(amount: formatBalanceText(amount)))
        topView.addSubview(headerView)
        NSLayoutConstraint.activate([
            headerView.leftAnchor.constraint(equalTo: topView.leftAnchor, constant: 32),
            headerView.rightAnchor.constraint(equalTo: topView.rightAnchor, constant: -32),
            headerView.centerYAnchor.constraint(equalTo: topView.centerYAnchor)
        ])
    }
    
    @objc func viewWalletPressed() {
        dismiss(animated: true)
    }
}
