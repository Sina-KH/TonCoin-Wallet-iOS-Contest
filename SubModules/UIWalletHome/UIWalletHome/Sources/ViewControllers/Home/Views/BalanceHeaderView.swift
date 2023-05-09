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
    func scanPressed()
    func settingsPressed()
    func receivePressed()
    func sendPressed()
}

public class BalanceHeaderView: UIView {
    
    // minimum height to show collapsed mode
    private static let minHeightWithoutRadiusView = CGFloat(44)
    // main content / it's smaller on iPhone 5s device
    private static let contentHeight = isIPhone5s ? CGFloat(212) : CGFloat(292)
    // gap for the view that have reversed corner radius on the bottom
    public static let bottomGap = CGFloat(0)

    private static let minHeight = minHeightWithoutRadiusView + bottomGap
    static let defaultHeight = contentHeight + bottomGap

    private weak var delegate: BalanceHeaderViewDelegate!
    private var heightConstraint: NSLayoutConstraint!
    private var actionsStackView: UIStackView!
    private var balanceView: BalanceView!
    private(set) var updateStatusView: UpdateStatusView!

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
        var constraints = [NSLayoutConstraint]()

        translatesAutoresizingMaskIntoConstraints = false
        layer.masksToBounds = true
        heightConstraint = heightAnchor.constraint(equalToConstant: 300)
        constraints.append(contentsOf: [
            heightConstraint
        ])
        backgroundColor = WTheme.balanceHeaderView.background

        // scan button
        let scanButton = WButton.setupInstance(.secondary)
        scanButton.translatesAutoresizingMaskIntoConstraints = false
        scanButton.tintColor = WTheme.balanceHeaderView.headIcons
        scanButton.setImage(UIImage(named: "ScanIcon")?.withRenderingMode(.alwaysTemplate), for: .normal)
        scanButton.addTarget(self, action: #selector(scanPressed), for: .touchUpInside)
        addSubview(scanButton)
        constraints.append(contentsOf: [
            scanButton.topAnchor.constraint(equalTo: topAnchor),
            scanButton.leftAnchor.constraint(equalTo: leftAnchor, constant: 8),
            scanButton.widthAnchor.constraint(equalToConstant: 44),
            scanButton.heightAnchor.constraint(equalToConstant: 44)
        ])

        // settings button
        let settingsButton = WButton.setupInstance(.secondary)
        settingsButton.translatesAutoresizingMaskIntoConstraints = false
        settingsButton.tintColor = WTheme.balanceHeaderView.headIcons
        settingsButton.setImage(UIImage(named: "SettingsIcon")?.withRenderingMode(.alwaysTemplate), for: .normal)
        settingsButton.addTarget(self, action: #selector(settingsPressed), for: .touchUpInside)
        addSubview(settingsButton)
        constraints.append(contentsOf: [
            settingsButton.topAnchor.constraint(equalTo: topAnchor),
            settingsButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -8),
            settingsButton.widthAnchor.constraint(equalToConstant: 44),
            settingsButton.heightAnchor.constraint(equalToConstant: 44)
        ])

        // balance view
        balanceView = BalanceView()
        balanceView.isUserInteractionEnabled = false
        addSubview(balanceView)
        constraints.append(contentsOf: [
            balanceView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -10),
            balanceView.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])

        // update status view
        updateStatusView = UpdateStatusView()
        addSubview(updateStatusView)
        constraints.append(contentsOf: [
            updateStatusView.topAnchor.constraint(equalTo: topAnchor),
            updateStatusView.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])

        // send/receive actions
        actionsStackView = UIStackView()
        actionsStackView.translatesAutoresizingMaskIntoConstraints = false
        actionsStackView.spacing = 12
        actionsStackView.distribution = .fillEqually
        addSubview(actionsStackView)
        constraints.append(contentsOf: [
            actionsStackView.leftAnchor.constraint(equalTo: leftAnchor, constant: 16),
            actionsStackView.rightAnchor.constraint(equalTo: rightAnchor, constant: -16),
            actionsStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16 - BalanceHeaderView.bottomGap)
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
        sendButton.addTarget(self, action: #selector(sendPressed), for: .touchUpInside)
        actionsStackView.addArrangedSubview(sendButton)

        NSLayoutConstraint.activate(constraints)
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
        
        // set balance view size
        let scale = newHeight > BalanceHeaderView.minHeight * 3 ? 1.5 :
            0.5 + (newHeight - BalanceHeaderView.minHeight) / BalanceHeaderView.minHeight / 2
        balanceView.update(scale: min(1, scale))
        updateStatusView.alpha = scale == 1.5 ? 1 : max(0, scale - 0.9) * 10 / 6
    }
    
    func update(balance: Int64) {
        balanceView.balance = balance
    }
    
    func update(status: UpdateStatusView.State) {
        updateStatusView.state = status
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
    
    @objc func scanPressed() {
        delegate?.scanPressed()
    }
    
    @objc func settingsPressed() {
        delegate?.settingsPressed()
    }

    @objc func receivePressed() {
        delegate.receivePressed()
    }
    
    @objc func sendPressed() {
        delegate.sendPressed()
    }
}
