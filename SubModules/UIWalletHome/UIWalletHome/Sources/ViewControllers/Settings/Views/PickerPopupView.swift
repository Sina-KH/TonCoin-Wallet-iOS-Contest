//
//  PickerPopupView.swift
//  UIWalletHome
//
//  Created by Sina on 5/4/23.
//

import UIKit
import WalletContext

protocol PickerPopupDelegate: AnyObject {
    func pickerItemSelected(item: PickerViewItem)
}

class PickerPopupView: UIView {
    
    static func presentPopup(`for` pickerView: PickerView) {
        _ = PickerPopupView(pickerView: pickerView)
    }

    private weak var pickerView: PickerView!
    private init(pickerView: PickerView) {
        self.pickerView = pickerView
        super.init(frame: .zero)
        setupViews()
    }
    
    private var popupView: UIView!
    
    required internal init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear

        // add to top view
        guard let topView = topViewController()?.view else { return }
        topView.addSubview(self)
        NSLayoutConstraint.activate([
            leftAnchor.constraint(equalTo: topView.leftAnchor),
            topAnchor.constraint(equalTo: topView.topAnchor),
            rightAnchor.constraint(equalTo: topView.rightAnchor),
            bottomAnchor.constraint(equalTo: topView.bottomAnchor)
        ])
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(outsidePressed)))

        // add popup
        popupView = UIView()
        popupView.translatesAutoresizingMaskIntoConstraints = false
        popupView.layer.cornerRadius = 10
        popupView.layer.borderWidth = 0.32
        popupView.layer.masksToBounds = true
        addSubview(popupView)
        let topConstraint = popupView.topAnchor.constraint(equalTo: pickerView.bottomAnchor)
        topConstraint.priority = UILayoutPriority(999)
        NSLayoutConstraint.activate([
            topConstraint,
            popupView.bottomAnchor.constraint(lessThanOrEqualTo: topView.bottomAnchor),
            popupView.trailingAnchor.constraint(equalTo: pickerView.trailingAnchor, constant: 8)
        ])
        
        // add items stack view
        let itemsStackView = UIStackView()
        itemsStackView.translatesAutoresizingMaskIntoConstraints = false
        popupView.addSubview(itemsStackView)
        NSLayoutConstraint.activate([
            itemsStackView.topAnchor.constraint(equalTo: popupView.topAnchor),
            itemsStackView.leftAnchor.constraint(equalTo: popupView.leftAnchor),
            itemsStackView.rightAnchor.constraint(equalTo: popupView.rightAnchor),
            itemsStackView.bottomAnchor.constraint(equalTo: popupView.bottomAnchor),
            itemsStackView.widthAnchor.constraint(equalToConstant: 100)
        ])
        itemsStackView.axis = .vertical
        for (i, item) in pickerView.items.enumerated() {
            // item's horizontal stack view
            let itemView = PickerPopupItemView(item: item,
                                               isSelected: item.id == pickerView.selectedID,
                                               separator: i < pickerView.items.count - 1,
                                               delegate: self)
            itemView.layoutMargins = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
            itemView.isLayoutMarginsRelativeArrangement = true
            itemView.alignment = .center
            itemView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                itemView.heightAnchor.constraint(equalToConstant: 40)
            ])
            itemsStackView.addArrangedSubview(itemView)
        }
        
        updateTheme()

        alpha = 0
        UIView.animate(withDuration: 0.1) {
            self.alpha = 1
        }
    }
    
    private func updateTheme() {
        popupView.backgroundColor = WTheme.background
        popupView.layer.borderColor = WTheme.border.cgColor
    }
    
    @objc private func outsidePressed() {
        dismissPopup()
    }
    
    func dismissPopup() {
        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = 0
        }) { finished in
            self.removeFromSuperview()
        }
    }

}

extension PickerPopupView: PickerPopupItemDelegate {
    func pickerPopupItemSelected(item: PickerViewItem) {
        pickerView?.pickerItemSelected(item: item)
        dismissPopup()
    }
}
