//
//  TonConnectVC.swift
//  UITonConnect
//
//  Created by Sina on 5/9/23.
//

import UIKit
import UIComponents
import WalletContext
import WalletCore
import AVFoundation

public class TonConnectVC: WViewController {

    private let walletContext: WalletContext
    private let walletInfo: WalletInfo
    private let tonConnectRequestLink: TonConnectRequestLink
    
    private lazy var tonConnectViewModel = TonConnectVM(
        walletContext: walletContext,
        walletInfo: walletInfo,
        tonConnectVMDelegate: self
    )
    
    public init(walletContext: WalletContext,
                walletInfo: WalletInfo,
                tonConnectRequestLink: TonConnectRequestLink) {
        self.walletContext = walletContext
        self.walletInfo = walletInfo
        self.tonConnectRequestLink = tonConnectRequestLink
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        tonConnectViewModel.loadManifest(url: tonConnectRequestLink.r.manifestUrl)
    }
    
    private var verticalStackView: UIStackView!
    private var topImageView: UIImageView!
    private var titleLabel: UILabel!
    private var textLabel: UILabel!
    private var connectButton: WButton!
    private var checkIcon: UIImageView!
    
    public override func loadView() {
        super.loadView()
        setupViews()
    }
    
    private func setupViews() {
        verticalStackView = UIStackView()
        verticalStackView.translatesAutoresizingMaskIntoConstraints = false
        verticalStackView.alpha = 0
        view.addSubview(verticalStackView)
        NSLayoutConstraint.activate([
            verticalStackView.topAnchor.constraint(equalTo: view.topAnchor),
            verticalStackView.leftAnchor.constraint(equalTo: view.leftAnchor),
            verticalStackView.rightAnchor.constraint(equalTo: view.rightAnchor),
            verticalStackView.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        verticalStackView.axis = .vertical
        verticalStackView.layoutMargins = UIEdgeInsets(top: 44, left: 16, bottom: 12, right: 16)
        verticalStackView.isLayoutMarginsRelativeArrangement = true
        
        // top image view showing connecting app icon
        let imageContainerView = UIView()
        imageContainerView.translatesAutoresizingMaskIntoConstraints = false
        topImageView = UIImageView()
        topImageView.translatesAutoresizingMaskIntoConstraints = false
        topImageView.layer.cornerRadius = 20
        topImageView.layer.masksToBounds = true
        imageContainerView.addSubview(topImageView)
        NSLayoutConstraint.activate([
            topImageView.widthAnchor.constraint(equalToConstant: 80),
            topImageView.heightAnchor.constraint(equalToConstant: 80),
            topImageView.topAnchor.constraint(equalTo: imageContainerView.topAnchor),
            topImageView.bottomAnchor.constraint(equalTo: imageContainerView.bottomAnchor),
            topImageView.centerXAnchor.constraint(equalTo: imageContainerView.centerXAnchor)
        ])
        verticalStackView.addArrangedSubview(imageContainerView)
        
        // gap
        verticalStackView.setCustomSpacing(20, after: imageContainerView)

        // title
        titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 22, weight: .semibold)
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        titleLabel.text = WStrings.Wallet_TonConnect_ConnectTo(app: "")
        verticalStackView.addArrangedSubview(titleLabel)
        
        // gap
        verticalStackView.setCustomSpacing(8, after: titleLabel)
        
        // connection text
        textLabel = UILabel()
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.font = .systemFont(ofSize: 17, weight: .regular)
        textLabel.numberOfLines = 0
        textLabel.textAlignment = .center
        textLabel.text = "\n"
        verticalStackView.addArrangedSubview(textLabel)

        // gap
        verticalStackView.setCustomSpacing(36, after: textLabel)

        // notice label
        let noticeLabel = UILabel()
        noticeLabel.translatesAutoresizingMaskIntoConstraints = false
        noticeLabel.font = .systemFont(ofSize: 15, weight: .regular)
        noticeLabel.numberOfLines = 0
        noticeLabel.textAlignment = .center
        noticeLabel.text = WStrings.Wallet_TonConnect_Notice.localized
        noticeLabel.textColor = WTheme.secondaryLabel
        verticalStackView.addArrangedSubview(noticeLabel)
        
        // gap
        verticalStackView.setCustomSpacing(24, after: noticeLabel)
        
        // connect button
        connectButton = WButton.setupInstance(.primary)
        connectButton.translatesAutoresizingMaskIntoConstraints = false
        connectButton.setTitle(WStrings.Wallet_TonConnect_ConnectWallet.localized, for: .normal)
        connectButton.addTarget(self, action: #selector(connectPressed), for: .touchUpInside)
        verticalStackView.addArrangedSubview(connectButton)
        
        // check icon
        checkIcon = UIImageView(image: UIImage(named: "CheckIcon")!.withRenderingMode(.alwaysTemplate))
        checkIcon.translatesAutoresizingMaskIntoConstraints = false
        checkIcon.tintColor = WTheme.primaryButton.background
        checkIcon.alpha = 0
        verticalStackView.addSubview(checkIcon)
        NSLayoutConstraint.activate([
            checkIcon.widthAnchor.constraint(equalToConstant: 34),
            checkIcon.heightAnchor.constraint(equalToConstant: 34),
            checkIcon.centerXAnchor.constraint(equalTo: connectButton.centerXAnchor),
            checkIcon.centerYAnchor.constraint(equalTo: connectButton.centerYAnchor)
        ])

        // close button
        let closeButton = UIButton(type: .system)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.setImage(UIImage(named: "CloseIcon")!.withRenderingMode(.alwaysTemplate), for: .normal)
        closeButton.addTarget(self, action: #selector(closePressed), for: .touchUpInside)
        closeButton.tintColor = WTheme.secondaryLabel
        closeButton.layer.cornerRadius = 16
        closeButton.backgroundColor = WTheme.groupedBackground
        view.addSubview(closeButton)
        NSLayoutConstraint.activate([
            closeButton.widthAnchor.constraint(equalToConstant: 32),
            closeButton.heightAnchor.constraint(equalToConstant: 32),
            closeButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 18),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    @objc func closePressed() {
        dismiss(animated: true)
    }
    
    @objc func connectPressed() {
        if isLoading {
            return
        }
        isLoading = true
        tonConnectViewModel.connect(request: tonConnectRequestLink)
    }
    
    var isLoading = false {
        didSet {
            connectButton.showLoading = isLoading
            view.isUserInteractionEnabled = !isLoading
        }
    }
}

extension TonConnectVC: TonConnectVMDelegate {
    func manifestLoaded(manifest: TonConnectManifest) {
        UIView.animate(withDuration: 0.25) { [weak self] in
            self?.verticalStackView.alpha = 1
        }

        let manifestURL = URL(string: manifest.url)?.host ?? ""
        // set connect request text
        textLabel.attributedText = WStrings.Wallet_TonConnect_RequestText(
            textAttr: [
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17)
            ],
            application: NSAttributedString(string: manifestURL, attributes: [
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17, weight: .regular)
            ]),
            address: NSAttributedString(string: formatStartEndAddress(walletInfo.address), attributes: [
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17, weight: .regular),
                NSAttributedString.Key.foregroundColor: WTheme.secondaryLabel
            ]),
            walletVersion: NSAttributedString(string: walletVersionString(version: walletInfo.version), attributes: [
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17, weight: .regular)
            ])
        )
        
        // set top image
        guard let imageURL = URL(string: manifest.iconUrl) else {
            topImageView.image = nil
            return
        }
        topImageView.download(from: imageURL)
    }
    func errorOccured() {
        isLoading = false
    }

    func tonConnected() {
        AudioServicesPlaySystemSound(SystemSoundID(1394))
        UIView.animate(withDuration: 0.25, animations: { [weak self] in
            guard let self else {
                return
            }
            connectButton.alpha = 0
            view.layoutIfNeeded()
        }) { [weak self] _ in
            UIView.animate(withDuration: 0.25, animations: { [weak self] in
                guard let self else {
                    return
                }
                checkIcon.alpha = 1
                view.layoutIfNeeded()
            }) { [weak self] _ in
                self?.dismiss(animated: true)
            }
        }
    }
}
