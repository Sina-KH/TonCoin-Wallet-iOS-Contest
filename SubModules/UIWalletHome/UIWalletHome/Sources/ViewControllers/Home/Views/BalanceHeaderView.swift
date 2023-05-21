//
//  BalanceHeaderView.swift
//  UIWalletHome
//
//  Created by Sina on 4/20/23.
//

import UIKit
import UIComponents
import WalletContext
import WalletCore
import SwiftSignalKit

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

    public static let minHeight = minHeightWithoutRadiusView + bottomGap
    public static let defaultHeight = contentHeight + bottomGap

    private var walletInfo: WalletInfo
    private weak var delegate: BalanceHeaderViewDelegate?
    private var heightConstraint: NSLayoutConstraint!
    private var actionsStackView: UIStackView!
    private var shortAddressLabel: UILabel!
    private var balanceView: BalanceView!
    private var updateStatusViewContainer: UIView!
    private(set) var updateStatusView: UpdateStatusView!
    private var rateLabel: UILabel!

    public init(walletInfo: WalletInfo, delegate: BalanceHeaderViewDelegate) {
        self.walletInfo = walletInfo
        self.delegate = delegate
        super.init(frame: CGRect.zero)
        setupView()
        setupRateUpdater()
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
        heightConstraint = heightAnchor.constraint(equalToConstant: BalanceHeaderView.contentHeight)
        constraints.append(contentsOf: [
            heightConstraint
        ])
        
        // background should be clear to let refresh control appear
        backgroundColor = .clear

        // scan button
        let scanButton = WBaseButton(type: .system)
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
        let settingsButton = WBaseButton(type: .system)
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
        balanceView = BalanceView(textColor: WTheme.balanceHeaderView.balance)
        balanceView.isUserInteractionEnabled = false
        addSubview(balanceView)
        constraints.append(contentsOf: [
            balanceView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -10),
            balanceView.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
        
        // short address label
        shortAddressLabel = UILabel()
        shortAddressLabel.translatesAutoresizingMaskIntoConstraints = false
        shortAddressLabel.font = .systemFont(ofSize: 17, weight: .regular)
        shortAddressLabel.textColor = WTheme.balanceHeaderView.balance
        shortAddressLabel.text = formatStartEndAddress(walletInfo.address)
        addSubview(shortAddressLabel)
        constraints.append(contentsOf: [
            shortAddressLabel.bottomAnchor.constraint(equalTo: balanceView.topAnchor, constant: -2),
            shortAddressLabel.centerXAnchor.constraint(equalTo: balanceView.centerXAnchor)
        ])

        // rate label
        rateLabel = UILabel()
        rateLabel.translatesAutoresizingMaskIntoConstraints = false
        rateLabel.textColor = WTheme.balanceHeaderView.balance.withAlphaComponent(0.6)
        rateLabel.font = .systemFont(ofSize: 13, weight: .regular)
        rateLabel.alpha = 0
        rateLabel.textAlignment = .center
        addSubview(rateLabel)
        let rateLabelTopConstraint = rateLabel.topAnchor.constraint(equalTo: balanceView.bottomAnchor)
        rateLabelTopConstraint.priority = .defaultHigh
        constraints.append(contentsOf: [
            rateLabelTopConstraint,
            rateLabel.centerXAnchor.constraint(equalTo: balanceView.centerXAnchor),
            rateLabel.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -6),
        ])

        // update status view
        updateStatusViewContainer = UIView()
        updateStatusViewContainer.translatesAutoresizingMaskIntoConstraints = false
        addSubview(updateStatusViewContainer)
        constraints.append(contentsOf: [
            updateStatusViewContainer.topAnchor.constraint(equalTo: topAnchor),
            updateStatusViewContainer.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
        updateStatusView = UpdateStatusView()
        updateStatusViewContainer.addSubview(updateStatusView)
        constraints.append(contentsOf: [
            updateStatusView.leftAnchor.constraint(equalTo: updateStatusViewContainer.leftAnchor),
            updateStatusView.rightAnchor.constraint(equalTo: updateStatusViewContainer.rightAnchor),
            updateStatusView.topAnchor.constraint(equalTo: updateStatusViewContainer.topAnchor),
            updateStatusView.bottomAnchor.constraint(equalTo: updateStatusViewContainer.bottomAnchor),
            updateStatusView.centerXAnchor.constraint(equalTo: updateStatusViewContainer.centerXAnchor),
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
    func updateHeight(scrollOffset: CGFloat) -> CGFloat {
        var newHeight = BalanceHeaderView.defaultHeight - scrollOffset

        // balance header view can not be smaller than 44pt
        if newHeight < BalanceHeaderView.minHeight {
            newHeight = BalanceHeaderView.minHeight
        }

        // set the new constraint
        heightConstraint.constant = newHeight

        // set actions and short address alpha
        actionsStackView.alpha = 1 - scrollOffset / 100
        shortAddressLabel.alpha = actionsStackView.alpha

        // set balance view size

        // scale is between 0.5 (collapsed) and 1.5 (expanded)
        let scale = newHeight > BalanceHeaderView.minHeight * 3 ? 1.5 :
            0.5 + (newHeight - BalanceHeaderView.minHeight) / BalanceHeaderView.minHeight / 2
        balanceView.update(scale: min(1, scale))

        updateStatusViewContainer.alpha = scale == 1.5 ? 1 : max(0, scale - 0.9) * 10 / 6
        
        // show rate value for selected currency if scrolled up
        //rateLabel.alpha = scale > 0.9 ? 0 : 1 - (scale - 0.5) * 10 / 4

        return newHeight
    }
    
    func update(balance: Int64) {
        balanceView.balance = balance
        updateRateLabel()
    }
    
    func update(status: UpdateStatusView.State, handleAnimation: Bool = true) {
        updateStatusView.setState(newState: status, handleAnimation: handleAnimation)
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
        delegate?.receivePressed()
    }
    
    @objc func sendPressed() {
        delegate?.sendPressed()
    }
    
    // MARK: - Currency Rates
    private var rateUpdaterTimer: SwiftSignalKit.Timer? = nil
    private var currencyPrices: RatesResponse.Rates.CurrencyRates.CurrencyPrices? = nil
    var selectedCurrencyID = UserDefaultsHelper.selectedCurrencyID() {
        didSet {
            updateRateLabel()
        }
    }
    private func setupRateUpdater() {
        rateUpdaterTimer?.invalidate()
        rateUpdaterTimer = SwiftSignalKit.Timer(timeout: 60, repeat: true, completion: { [weak self] in
            self?.updateRate()
        }, queue: Queue.mainQueue())
        rateUpdaterTimer?.start()
        updateRate()
    }
    private func updateRate() {
        guard let url = URL(string: "https://tonapi.io/v2/rates?tokens=ton&currencies=ton%2Cusd%2Crub%2Ceur") else {
            return
        }
        _ = (Downloader.download(url: url) |> deliverOnMainQueue).start(next: { [weak self] data in
            guard let self else { return }
            let ratesResponse = try? JSONDecoder().decode(RatesResponse.self, from: data)
            currencyPrices = ratesResponse?.rates.TON.prices
            updateRateLabel()
        }, completed: {
        })
    }

    // update rate on updates of `balance`, `price` or `selected currency`
    private func updateRateLabel() {
        rateLabel.text = ""
        guard let balance = Double(formatBalanceText(balanceView.balance)) else { return }
        switch selectedCurrencyID {
        case CurrencyIDs.USD.rawValue:
            if let currencyPrice = currencyPrices?.USD {
                let amount = floor(currencyPrice * balance * 100) / 100
                rateLabel.text = "≈ $\(amount)"
            }
            break
        case CurrencyIDs.EUR.rawValue:
            if let currencyPrice = currencyPrices?.EUR {
                let amount = floor(currencyPrice * balance * 100) / 100
                rateLabel.text = "≈ €\(amount)"
            }
            break
        case CurrencyIDs.RUB.rawValue:
            if let currencyPrice = currencyPrices?.USD {
                let amount = floor(currencyPrice * balance * 10) / 10
                rateLabel.text = "≈ ₽\(amount)"
            }
            break
        default:
            break
        }        
        // formatted balance makes minus values positive, so we use real val from balanceView to check for flags (-1: empty and -2: loading)
        rateLabel.isHidden = balanceView.balance == -2
        if rateLabel.alpha == 0 && !rateLabel.isHidden {
            UIView.animate(withDuration: 0.3) { [weak self] in
                self?.rateLabel.alpha = 1
            }
        }
    }
}
