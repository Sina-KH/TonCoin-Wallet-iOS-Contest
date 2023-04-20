//
//  WordListView.swift
//  UICreateWallet
//
//  Created by Sina on 4/14/23.
//

import UIKit

class WordListView: UIView {

    init(words: [String]) {
        super.init(frame: CGRect.zero)
        setupView(words: words)
    }
    
    override init(frame: CGRect) {
        fatalError()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }

    private func setupView(words: [String]) {
        translatesAutoresizingMaskIntoConstraints = false

        // prepare stack views
        let rowsCount = Int(ceil(Double(words.count) / 2))
        let leftStackView = UIStackView()
        leftStackView.axis = .vertical
        leftStackView.spacing = 12
        let rightStackView = UIStackView()
        rightStackView.axis = .vertical
        rightStackView.spacing = 12
        
        // fill stack views with word items
        for (index, word) in words.enumerated() {
            let wordItemView = WordListItemView(index: index, word: word)
            if index < rowsCount {
                leftStackView.addArrangedSubview(wordItemView)
            } else {
                rightStackView.addArrangedSubview(wordItemView)
            }
        }
        
        // left side stackView
        leftStackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(leftStackView)
        NSLayoutConstraint.activate([
            leftStackView.leftAnchor.constraint(equalTo: leftAnchor),
            leftStackView.topAnchor.constraint(equalTo: topAnchor),
            leftStackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        rightStackView.translatesAutoresizingMaskIntoConstraints = false
        
        // right side stackView
        addSubview(rightStackView)
        NSLayoutConstraint.activate([
            rightStackView.rightAnchor.constraint(equalTo: rightAnchor),
            rightStackView.leftAnchor.constraint(greaterThanOrEqualTo: leftStackView.rightAnchor),
            rightStackView.topAnchor.constraint(equalTo: topAnchor),
            rightStackView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor)
        ])

    }

}
