//
//  SendingVC.swift
//  UIWalletSend
//
//  Created by Sina on 4/28/23.
//

import UIKit
import UIComponents
import WalletContext
import WalletCore

public class SendingVC: WViewController {
    
    // MARK: - Initializer
    private let walletContext: WalletContext
    private let walletInfo: WalletInfo
    private let sendInstanceData: SendInstanceData
    public init(walletContext: WalletContext, walletInfo: WalletInfo, sendInstanceData: SendInstanceData) {
        self.walletContext = walletContext
        self.walletInfo = walletInfo
        self.sendInstanceData = sendInstanceData
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var sendingVM = SendingVM(walletContext: walletContext,
                                           walletInfo: walletInfo,
                                           sendingVMDelegate: self)
    
    public override func loadView() {
        super.loadView()
        setupViews()
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        sendingVM.sendNow(sendInstanceData: sendInstanceData, forceIfDestinationNotInitialized: false)
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
        let headerView = HeaderView(animationName: "Waiting TON",
                                    animationPlaybackMode: .loop,
                                    title: WStrings.Wallet_Sending_Title.localized,
                                    description: WStrings.Wallet_Sending_Text.localized)
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

extension SendingVC: SendingVMDelegate {
    func sent(address: String, amount: Int64) {
        navigationController?.pushViewController(SentVC(address: address, amount: amount), animated: true)
    }

    func errorOccured() {
        // errors are handled in the view model due to the fact that
        //  user may change active vc during the send process and error should appear on the most top vc
        navigationController?.popViewController(animated: true)
    }
    
    func canceled() {
        navigationController?.popViewController(animated: true)
    }
}
