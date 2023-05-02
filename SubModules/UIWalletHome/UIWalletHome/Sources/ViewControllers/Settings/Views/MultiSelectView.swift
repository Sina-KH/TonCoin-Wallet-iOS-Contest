//
//  MultiSelectView.swift
//  UIWalletHome
//
//  Created by Sina on 5/2/23.
//

import UIKit

struct MultiSelectItem {
    var id: Int
    var name: String
}

class MultiSelectView: UIView {
    
    private var items: [MultiSelectItem]
    private var selectedID: Int

    init(items: [MultiSelectItem], selectedID: Int) {
        self.items = items
        self.selectedID = selectedID
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
