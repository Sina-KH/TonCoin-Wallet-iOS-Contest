//
//  PickerView.swift
//  UIWalletHome
//
//  Created by Sina on 5/2/23.
//

import UIKit
import WalletContext

struct PickerViewItem {
    var id: Int
    var name: String
}

class PickerView: UIView {
    
    private (set) var items: [PickerViewItem]
    private (set) var selectedID: Int {
        didSet {
            updateSelectedItemLabel()
        }
    }
    private var onChange: ((PickerViewItem) -> Void)? = nil

    init(items: [PickerViewItem], selectedID: Int, onChange: @escaping (PickerViewItem) -> Void) {
        self.items = items
        self.selectedID = selectedID
        self.onChange = onChange
        super.init(frame: .zero)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var multiSelectIcon: UIImageView!
    private var selectedItemLabel: UILabel!
    
    func setupViews() {
        // multi select icon
        multiSelectIcon = UIImageView(image: UIImage(named: "PickerIcon")!.withRenderingMode(.alwaysTemplate))
        multiSelectIcon.translatesAutoresizingMaskIntoConstraints = false
        addSubview(multiSelectIcon)
        NSLayoutConstraint.activate([
            multiSelectIcon.trailingAnchor.constraint(equalTo: trailingAnchor),
            multiSelectIcon.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        // selected item label
        selectedItemLabel = UILabel()
        selectedItemLabel.translatesAutoresizingMaskIntoConstraints = false
        selectedItemLabel.font = .systemFont(ofSize: 17, weight: .regular)
        addSubview(selectedItemLabel)
        NSLayoutConstraint.activate([
            selectedItemLabel.trailingAnchor.constraint(equalTo: multiSelectIcon.leadingAnchor, constant: -6),
            selectedItemLabel.topAnchor.constraint(equalTo: topAnchor),
            selectedItemLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            selectedItemLabel.leadingAnchor.constraint(equalTo: leadingAnchor)
        ])
        
        // gesture recognizer
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(pickerPressed)))
        
        updateTheme()
        updateSelectedItemLabel()
    }
    
    func updateTheme() {
        multiSelectIcon.tintColor = WTheme.tint
        selectedItemLabel.textColor = WTheme.tint
    }
    
    private func updateSelectedItemLabel() {
        selectedItemLabel?.text = items.first(where: { it in
            it.id == selectedID
        })?.name
    }
    
    @objc func pickerPressed() {
        PickerPopupView.presentPopup(for: self)
    }
    
}

extension PickerView: PickerPopupDelegate {
    func pickerItemSelected(item: PickerViewItem) {
        selectedID = item.id
    }
}
