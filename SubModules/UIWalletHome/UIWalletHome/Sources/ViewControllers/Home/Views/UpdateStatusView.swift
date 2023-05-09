//
//  UpdateStatusView.swift
//  UIWalletHome
//
//  Created by Sina on 5/4/23.
//

import UIKit
import UIComponents
import WalletContext

public class UpdateStatusView: UIStackView {
    
    public init() {
        super.init(frame: CGRect.zero)
        setupViews()
    }
    
    override public init(frame: CGRect) {
        fatalError()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var activityIndicator: UIActivityIndicatorView!
    private var statusLabel: UILabel!
    
    private func setupViews() {
        translatesAutoresizingMaskIntoConstraints = false
        spacing = 8
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 44)
        ])

        alignment = .center
        activityIndicator = UIActivityIndicatorView()
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.color = WTheme.balanceHeaderView.balance
        activityIndicator.hidesWhenStopped = true
        addArrangedSubview(activityIndicator)
        statusLabel = UILabel()
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.textColor = WTheme.balanceHeaderView.balance
        statusLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        addArrangedSubview(statusLabel)
    }
    
    enum State: Equatable {
        case waitingForNetwork
        case connecting
        case updating(progress: Int)
        case updated
    }
    
    var state: State = .updated {
        didSet {
            let targetAlpha: CGFloat
            switch state {
            case .waitingForNetwork:
                targetAlpha = 1
                activityIndicator.startAnimating()
                statusLabel.text = WStrings.Wallet_Home_WaitingForNetwork.localized
                break
            case .connecting:
                targetAlpha = 1
                activityIndicator.startAnimating()
                statusLabel.text = WStrings.Wallet_Home_Connecting.localized
                break
            case let .updating(progress):
                targetAlpha = 1
                activityIndicator.startAnimating()
                statusLabel.text = WStrings.Wallet_Home_Updating.localized + " (\(progress)%)"
                break
            case .updated:
                targetAlpha = 0
                break
            }
            if alpha != targetAlpha {
                UIView.animate(withDuration: 0.2, animations: {
                    self.alpha = targetAlpha
                }) { _ in
                    // set hidden to prevent appearance from header view alpha controls
                    self.isHidden = targetAlpha == 0
                }
            }
        }
    }
}
