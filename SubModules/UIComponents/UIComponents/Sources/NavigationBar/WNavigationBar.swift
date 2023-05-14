//
//  WNavigationBar.swift
//  UIComponents
//
//  Created by Sina on 4/29/23.
//

import UIKit
import WalletContext

public struct WNavigationBarButton {
    let text: String
    let icon: UIImage?
    let onPress: () -> Void
    public init(text: String, icon: UIImage? = nil, onPress: @escaping () -> Void) {
        self.text = text
        self.icon = icon
        self.onPress = onPress
    }
}

public class WNavigationBar: UIView {

    private let title: String?
    private let leadingItem: WNavigationBarButton?
    private let trailingItem: WNavigationBarButton?
    public init(title: String? = nil,
                leadingItem: WNavigationBarButton? = nil,
                trailingItem: WNavigationBarButton? = nil) {
        self.title = title
        self.leadingItem = leadingItem
        self.trailingItem = trailingItem
        super.init(frame: .zero)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 56)
        ])
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])

        if let leadingItem {
            let leadingButton = WButton.setupInstance(.secondary)
            if let icon = leadingItem.icon {
                leadingButton.setImage(icon, for: .normal)
                leadingButton.centerTextAndImage(spacing: 8)
            }
            leadingButton.setTitle(leadingItem.text, for: .normal)
            leadingButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
            leadingButton.translatesAutoresizingMaskIntoConstraints = false
            addSubview(leadingButton)
            NSLayoutConstraint.activate([
                leadingButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
                leadingButton.centerYAnchor.constraint(equalTo: centerYAnchor)
            ])
            leadingButton.addTarget(self, action: #selector(leadingItemPressed), for: .touchUpInside)
        }

        if let trailingItem {
            let trailingButton = WButton.setupInstance(.secondary)
            if let icon = trailingItem.icon {
                trailingButton.setImage(icon, for: .normal)
            }
            trailingButton.setTitle(trailingItem.text, for: .normal)
            trailingButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
            trailingButton.translatesAutoresizingMaskIntoConstraints = false
            addSubview(trailingButton)
            NSLayoutConstraint.activate([
                trailingButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
                trailingButton.centerYAnchor.constraint(equalTo: centerYAnchor)
            ])
            trailingButton.addTarget(self, action: #selector(trailingItemPressed), for: .touchUpInside)
        }
    }
    
    @objc func leadingItemPressed() {
        leadingItem?.onPress()
    }

    @objc func trailingItemPressed() {
        trailingItem?.onPress()
    }
    
}
