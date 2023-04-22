//
//  BalanceHeaderView.swift
//  UIWalletHome
//
//  Created by Sina on 4/20/23.
//

import UIKit
import UIComponents
import WalletContext

public protocol BalanceHeaderViewDelegate: AnyObject {
    func receivePressed()
}

public class BalanceHeaderView: UIView {
    
    // minimum height to show collapsed mode
    private static let minHeightWithoutRadiusView = CGFloat(44)
    // main content / it's smaller on iPhone 5s device
    private static let contentHeight = isIPhone5s ? CGFloat(212) : CGFloat(292)
    // view addded to bottom of the view to have reversed corner radius
    private static let bottomRadiusViewHeight = CGFloat(32)

    private static let minHeight = minHeightWithoutRadiusView + bottomRadiusViewHeight
    static let defaultHeight = contentHeight + bottomRadiusViewHeight

    private weak var delegate: BalanceHeaderViewDelegate!
    private var heightConstraint: NSLayoutConstraint!
    private var actionsStackView: UIStackView!
    private var balanceView: BalanceView!

    public init(delegate: BalanceHeaderViewDelegate) {
        self.delegate = delegate
        super.init(frame: CGRect.zero)
        setupView()
    }

    override public init(frame: CGRect) {
        fatalError()
    }
    
    required public init?(coder: NSCoder) {
        fatalError()
    }

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        layer.masksToBounds = true
        heightConstraint = heightAnchor.constraint(equalToConstant: 300)
        NSLayoutConstraint.activate([
            heightConstraint
        ])
        backgroundColor = currentTheme.balanceHeaderView.background

        // settings button
        let settingsButton = WButton.setupInstance(.secondary)
        settingsButton.translatesAutoresizingMaskIntoConstraints = false
        settingsButton.tintColor = currentTheme.balanceHeaderView.headIcons
        settingsButton.setImage(UIImage(named: "SettingsIcon")?.withRenderingMode(.alwaysTemplate), for: .normal)
        addSubview(settingsButton)
        NSLayoutConstraint.activate([
            settingsButton.topAnchor.constraint(equalTo: topAnchor),
            settingsButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -8),
            settingsButton.widthAnchor.constraint(equalToConstant: 44),
            settingsButton.heightAnchor.constraint(equalToConstant: 44)
        ])

        // scan button
        let scanButton = WButton.setupInstance(.secondary)
        scanButton.translatesAutoresizingMaskIntoConstraints = false
        scanButton.tintColor = currentTheme.balanceHeaderView.headIcons
        scanButton.setImage(UIImage(named: "ScanIcon")?.withRenderingMode(.alwaysTemplate), for: .normal)
        addSubview(scanButton)
        NSLayoutConstraint.activate([
            scanButton.topAnchor.constraint(equalTo: topAnchor),
            scanButton.leftAnchor.constraint(equalTo: leftAnchor, constant: 8),
            scanButton.widthAnchor.constraint(equalToConstant: 44),
            scanButton.heightAnchor.constraint(equalToConstant: 44)
        ])

        // balance view
        balanceView = BalanceView()
        addSubview(balanceView)
        NSLayoutConstraint.activate([
            balanceView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -10),
            balanceView.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])

        // bottom corner radius
        let bottomCornersView = UIView()
        bottomCornersView.translatesAutoresizingMaskIntoConstraints = false
        bottomCornersView.backgroundColor = currentTheme.background
        bottomCornersView.layer.cornerRadius = BalanceHeaderView.bottomRadiusViewHeight / 2
        addSubview(bottomCornersView)
        NSLayoutConstraint.activate([
            bottomCornersView.leftAnchor.constraint(equalTo: leftAnchor, constant: 0),
            bottomCornersView.rightAnchor.constraint(equalTo: rightAnchor, constant: 0),
            bottomCornersView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: BalanceHeaderView.bottomRadiusViewHeight / 2),
            bottomCornersView.heightAnchor.constraint(equalToConstant: BalanceHeaderView.bottomRadiusViewHeight)
        ])

        // send/receive actions
        actionsStackView = UIStackView()
        actionsStackView.translatesAutoresizingMaskIntoConstraints = false
        actionsStackView.spacing = 12
        actionsStackView.distribution = .fillEqually
        addSubview(actionsStackView)
        NSLayoutConstraint.activate([
            actionsStackView.leftAnchor.constraint(equalTo: leftAnchor, constant: 16),
            actionsStackView.rightAnchor.constraint(equalTo: rightAnchor, constant: -16),
            actionsStackView.bottomAnchor.constraint(equalTo: bottomCornersView.topAnchor, constant: -16)
        ])

        let receiveButton = WButton.setupInstance(.accent)
        receiveButton.translatesAutoresizingMaskIntoConstraints = false
        receiveButton.setTitle(WStrings.Wallet_Home_Receive.localized, for: .normal)
        receiveButton.setImage(UIImage(named: "ReceiveIcon")?.withRenderingMode(.alwaysTemplate), for: .normal)
        receiveButton.centerTextAndImage(spacing: 8)
        receiveButton.addTarget(self, action: #selector(receivePressed), for: .touchUpInside)
        actionsStackView.addArrangedSubview(receiveButton)

        let sendButton = WButton.setupInstance(.accent)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.setTitle(WStrings.Wallet_Home_Send.localized, for: .normal)
        sendButton.setImage(UIImage(named: "SendIcon")?.withRenderingMode(.alwaysTemplate), for: .normal)
        sendButton.centerTextAndImage(spacing: 8)
        actionsStackView.addArrangedSubview(sendButton)

    }

    // update height
    func updateHeight(scrollOffset: CGFloat) {
        var newHeight = BalanceHeaderView.defaultHeight - scrollOffset

        // balance header view can not be smaller than 44pt
        if newHeight < BalanceHeaderView.minHeight {
            newHeight = BalanceHeaderView.minHeight
        }

        // set the new constraint
        heightConstraint.constant = newHeight

        // set actions alpha
        actionsStackView.alpha = 1 - scrollOffset / 100
    }
    
    func update(balance: Int64) {
        balanceView.balance = balance
    }

    // pass touch events to below view
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        if hitView == self {
            return nil
        } else {
            return hitView
        }
    }

    @objc func receivePressed() {
        delegate.receivePressed()
    }
}
