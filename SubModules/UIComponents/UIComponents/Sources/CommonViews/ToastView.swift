//
//  ToastView.swift
//  UIComponents
//
//  Created by Sina on 4/23/23.
//

import UIKit
import WalletContext

public class ToastView: UIView {

    public static func presentAbove(_ view: UIView, icon: UIImage, title: String, text: String) {
        let toastView = ToastView(icon: icon, title: title, text: text)
        view.superview?.addSubview(toastView)
        NSLayoutConstraint.activate([
            toastView.leftAnchor.constraint(equalTo: view.leftAnchor),
            toastView.rightAnchor.constraint(equalTo: view.rightAnchor),
            toastView.bottomAnchor.constraint(equalTo: view.topAnchor, constant: -12)
        ])
        toastView.alpha = 0
        toastView.layoutIfNeeded()
        UIView.animate(withDuration: 0.25) {
            toastView.alpha = 1
            toastView.layoutIfNeeded()
        }
        UIView.animate(withDuration: 0.25, delay: 5.25, animations: {
            toastView.alpha = 0
            toastView.layoutIfNeeded()
        }) { _ in
            toastView.removeFromSuperview()
        }
    }

    // MARK: - Initializers
    private init(icon: UIImage, title: String, text: String) {
        super.init(frame: CGRect.zero)
        setupView(icon: icon, title: title, text: text)
    }

    override private init(frame: CGRect) {
        fatalError()
    }
    
    required internal init?(coder: NSCoder) {
        fatalError()
    }

    // MARK: - Toast view setup
    private var iconView: UIImageView!
    private var titleLabel: UILabel!
    private var messageLabel: UILabel!

    private func setupView(icon: UIImage, title: String, text: String) {
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = 10
        NSLayoutConstraint.activate([
            heightAnchor.constraint(greaterThanOrEqualToConstant: 54)
        ])

        // add container stack view
        let horizontalStackView = UIStackView()
        horizontalStackView.layoutMargins = UIEdgeInsets(top: 9, left: 16, bottom: 9, right: 16)
        horizontalStackView.isLayoutMarginsRelativeArrangement = true
        horizontalStackView.spacing = 16
        horizontalStackView.translatesAutoresizingMaskIntoConstraints = false
        horizontalStackView.alignment = .center
        addSubview(horizontalStackView)
        NSLayoutConstraint.activate([
            horizontalStackView.leftAnchor.constraint(equalTo: leftAnchor),
            horizontalStackView.topAnchor.constraint(equalTo: topAnchor),
            horizontalStackView.rightAnchor.constraint(equalTo: rightAnchor),
            horizontalStackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        // leading icon
        iconView = UIImageView(image: icon.withRenderingMode(.alwaysTemplate))
        iconView.translatesAutoresizingMaskIntoConstraints = false
        horizontalStackView.addArrangedSubview(iconView)
        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 20),
            iconView.heightAnchor.constraint(equalToConstant: 20)
        ])

        // message stack view
        let messageStackView = UIStackView()
        messageStackView.translatesAutoresizingMaskIntoConstraints = false
        messageStackView.axis = .vertical
        messageStackView.alignment = .leading
        messageStackView.distribution = .fill
        messageStackView.spacing = 2
        horizontalStackView.addArrangedSubview(messageStackView)
        // message title
        titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.heightAnchor.constraint(equalToConstant: 17)
        ])
        titleLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        titleLabel.text = title
        messageStackView.addArrangedSubview(titleLabel)
        // message description
        messageLabel = UILabel()
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.font = .systemFont(ofSize: 14, weight: .regular)
        messageLabel.numberOfLines = 0
        messageLabel.text = text
        messageStackView.addArrangedSubview(messageLabel)

        updateTheme()
    }

    func updateTheme() {
        backgroundColor = WTheme.toastView.background
        iconView.tintColor = WTheme.toastView.tint
        titleLabel.textColor = WTheme.toastView.tint
        messageLabel.textColor = WTheme.toastView.tint
    }
}
