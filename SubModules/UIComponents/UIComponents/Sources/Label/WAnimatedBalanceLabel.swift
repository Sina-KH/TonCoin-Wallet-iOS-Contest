//
//  WAnimatedBalanceLabel.swift
//  UIComponents
//
//  Created by Sina on 5/26/23.
//

import UIKit
import WalletContext

public class WAnimatedBalanceLabel: UIView {
    
    private static let defaultNumberFont = UIFont.systemFont(ofSize: 48, weight: .semibold)
    private static let defaultDecimalsFont = UIFont.systemFont(ofSize: 30, weight: .semibold)
    
    private let numberFont: UIFont
    private let decimalsFont: UIFont
    public init(numberFont: UIFont? = nil, decimalsFont: UIFont? = nil) {
        self.numberFont = numberFont ?? WAnimatedBalanceLabel.defaultNumberFont
        self.decimalsFont = decimalsFont ?? WAnimatedBalanceLabel.defaultDecimalsFont
        super.init(frame: CGRect.zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    public override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setup()
    }
    
    public var numberLabel: LTMorphingLabel!
    public var decimalsLabel: LTMorphingLabel!
    private var widthConstraint: NSLayoutConstraint!
    
    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        
        numberLabel = LTMorphingLabel()
        numberLabel.translatesAutoresizingMaskIntoConstraints = false
        numberLabel.font = numberFont
        addSubview(numberLabel)
        NSLayoutConstraint.activate([
            numberLabel.leftAnchor.constraint(equalTo: leftAnchor),
            numberLabel.topAnchor.constraint(equalTo: topAnchor),
            numberLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        decimalsLabel = LTMorphingLabel()
        decimalsLabel.translatesAutoresizingMaskIntoConstraints = false
        decimalsLabel.font = decimalsFont
        addSubview(decimalsLabel)
        let rightAnchorConstraint = decimalsLabel.rightAnchor.constraint(equalTo: rightAnchor)
        rightAnchorConstraint.priority = .defaultLow
        NSLayoutConstraint.activate([
            decimalsLabel.leftAnchor.constraint(equalTo: numberLabel.rightAnchor),
            decimalsLabel.firstBaselineAnchor.constraint(equalTo: numberLabel.firstBaselineAnchor),
            rightAnchorConstraint
        ])
        
        widthConstraint = widthAnchor.constraint(equalToConstant: 0)
        NSLayoutConstraint.activate([
            widthConstraint,
        ])
        
        // set theme colors
        updateTheme()
    }
    
    func updateTheme() {
    }
    
    public var amount: Int64? = nil {
        didSet {
            // check if amount is loading
            guard let amount else {
                numberLabel.text = nil
                decimalsLabel.text = nil
                UIView.animate(withDuration: 0.6) { [weak self] in
                    guard let self else {return}
                    widthConstraint.constant = 0
                }
                return
            }
            // split amount number and decimals
            let components = formatBalanceText(amount).components(separatedBy: ".")
            // animate numebr
            numberLabel.text = "\(components[0])"
            superview?.layoutIfNeeded()
            UIView.animate(withDuration: Double(numberLabel.morphingDuration / 2)) { [weak self] in
                guard let self else {return}
                widthConstraint.constant = max(widthConstraint.constant, CGFloat(numberLabel.totalWidth + decimalsLabel.totalWidth))
                superview?.layoutIfNeeded()
            }
            // with a delay animate decimals, also.
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(numberLabel.morphingDuration / 2)) { [weak self] in
                guard let self else {
                    return
                }
                decimalsLabel.text = components.count > 1 ? ".\(components[1])" : nil
                superview?.layoutIfNeeded()
                UIView.animate(withDuration: Double(numberLabel.morphingDuration)) { [weak self] in
                    guard let self else {return}
                    widthConstraint.constant = CGFloat(numberLabel.totalWidth + decimalsLabel.totalWidth)
                    superview?.layoutIfNeeded()
                }
            }
        }
    }
    
    public var textColor: UIColor = .black {
        didSet {
            numberLabel.textColor = textColor
            decimalsLabel.textColor = textColor
        }
    }

    // called to update width on font updates
    public func updateWidth() {
        widthConstraint.constant = CGFloat(numberLabel.totalWidth + decimalsLabel.totalWidth)
    }
    
}
