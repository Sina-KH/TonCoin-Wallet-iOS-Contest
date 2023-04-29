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
    let onPress: () -> Void
    public init(text: String, onPress: @escaping () -> Void) {
        self.text = text
        self.onPress = onPress
    }
}

public class WNavigationBar: UIView {

    private let title: String
    private let trailingItem: WNavigationBarButton
    public init(title: String, trailingItem: WNavigationBarButton) {
        self.title = title
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
        
        let trailingButton = WButton.setupInstance(.secondary)
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
    
    @objc func trailingItemPressed() {
        trailingItem.onPress()
    }
}
