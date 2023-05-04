//
//  PickerPopupItemView.swift
//  UIWalletHome
//
//  Created by Sina on 5/4/23.
//

import UIKit
import WalletContext

protocol PickerPopupItemDelegate: AnyObject {
    func pickerPopupItemSelected(item: PickerViewItem)
}

class PickerPopupItemView: UIStackView {
    
    private let item: PickerViewItem!
    private let isSelected: Bool!
    private weak var delegate: PickerPopupItemDelegate?

    init(item: PickerViewItem,
         isSelected: Bool,
         separator: Bool,
         delegate: PickerPopupItemDelegate) {
        self.item = item
        self.isSelected = isSelected
        self.delegate = delegate
        super.init(frame: .zero)
        setupViews(separator: separator)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews(separator: Bool) {
        // item label
        let itemLabelView = UILabel()
        itemLabelView.font = .systemFont(ofSize: 17, weight: .medium)
        itemLabelView.text = item.name
        addArrangedSubview(itemLabelView)
        // TODO:: Add info label?
        // checkmark
        let itemCheckmarkIcon = UIImageView(image: UIImage(named: "PickerCheckmarkIcon")!.withRenderingMode(.alwaysTemplate))
        itemCheckmarkIcon.translatesAutoresizingMaskIntoConstraints = false
        itemCheckmarkIcon.isHidden = !isSelected
        addArrangedSubview(itemCheckmarkIcon)
        if separator {
            let separatorView = UIView()
            separatorView.translatesAutoresizingMaskIntoConstraints = false
            separatorView.backgroundColor = WTheme.separator
            addSubview(separatorView)
            NSLayoutConstraint.activate([
                separatorView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
                separatorView.trailingAnchor.constraint(equalTo: trailingAnchor),
                separatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
                separatorView.heightAnchor.constraint(equalToConstant: 0.33)
            ])
        }
        
        // tap gesture recognizer
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(itemSelected)))
    }
    
    @objc func itemSelected() {
        delegate?.pickerPopupItemSelected(item: item)
    }
}
