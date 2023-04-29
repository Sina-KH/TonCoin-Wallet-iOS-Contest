//
//  BubbleView.swift
//  UIWalletHome
//
//  Created by Sina on 4/22/23.
//

import UIKit
import WalletContext

class BubbleView: UIView {

    static let padding = CGFloat(12)

    let bubbleLayer = CAShapeLayer()

    private let chatLabel: UILabel = {
        let v = UILabel()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.numberOfLines = 0
        v.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        return v
    }()
    lazy var topConstraint = chatLabel.topAnchor.constraint(equalTo: topAnchor, constant: BubbleView.padding)
    lazy var leadingConstraint = chatLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: BubbleView.padding)
    lazy var trailingConstraint = chatLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -BubbleView.padding)
    lazy var bottomConstraint = chatLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -BubbleView.padding)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }

    func setupViews() -> Void {
        layer.masksToBounds = true

        // add the bubble layer
        layer.addSublayer(bubbleLayer)

        // add the label
        addSubview(chatLabel)

        NSLayoutConstraint.activate([topConstraint, leadingConstraint, trailingConstraint, bottomConstraint])
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let width = bounds.size.width
        let height = bounds.size.height

        let bezierPath = UIBezierPath()

        bezierPath.move(to: CGPoint(x: 22, y: height))
        bezierPath.addLine(to: CGPoint(x: width - 17, y: height))
        bezierPath.addCurve(to: CGPoint(x: width, y: height - 17), controlPoint1: CGPoint(x: width - 7.61, y: height), controlPoint2: CGPoint(x: width, y: height - 7.61))
        bezierPath.addLine(to: CGPoint(x: width, y: 17))
        bezierPath.addCurve(to: CGPoint(x: width - 17, y: 0), controlPoint1: CGPoint(x: width, y: 7.61), controlPoint2: CGPoint(x: width - 7.61, y: 0))
        bezierPath.addLine(to: CGPoint(x: 21, y: 0))
        bezierPath.addCurve(to: CGPoint(x: 4, y: 17), controlPoint1: CGPoint(x: 11.61, y: 0), controlPoint2: CGPoint(x: 4, y: 7.61))
        bezierPath.addLine(to: CGPoint(x: 4, y: height - 11))
        bezierPath.addCurve(to: CGPoint(x: 0, y: height), controlPoint1: CGPoint(x: 4, y: height - 1), controlPoint2: CGPoint(x: 0, y: height))
        bezierPath.addLine(to: CGPoint(x: -0.05, y: height - 0.01))
        bezierPath.addCurve(to: CGPoint(x: 11.04, y: height - 4.04), controlPoint1: CGPoint(x: 4.07, y: height + 0.43), controlPoint2: CGPoint(x: 8.16, y: height - 1.06))
        bezierPath.addCurve(to: CGPoint(x: 22, y: height), controlPoint1: CGPoint(x: 16, y: height), controlPoint2: CGPoint(x: 19, y: height))
        bezierPath.close()

        bubbleLayer.fillColor = WTheme.groupedBackground.cgColor

        bubbleLayer.path = bezierPath.cgPath
    }
    
    public var text: String = "" {
        didSet {
            chatLabel.text = text
            /* not required, as we remove the entire bubble view from the container if it's empty!
            if text.count == 0 {
                topConstraint.constant = 0
                leadingConstraint.constant = 0
                trailingConstraint.constant = 0
                bottomConstraint.constant = 0
            } else {
                topConstraint.constant = BubbleView.padding
                leadingConstraint.constant = BubbleView.padding
                trailingConstraint.constant = -BubbleView.padding
                bottomConstraint.constant = -BubbleView.padding
            }
             */
        }
    }
}
