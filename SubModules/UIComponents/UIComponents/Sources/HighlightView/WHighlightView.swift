//
//  WHighlightView.swift
//  UIComponents
//
//  Created by Sina on 5/4/23.
//

import UIKit

public class WHighlightView: UIView {

    public init() {
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // if `highlightBackgroundColor` is set, the view background will be changed to the new color on highlight
    public var highlightBackgroundColor: UIColor? = nil {
        didSet {
            if !isHighlighted {
                oldBackground = highlightBackgroundColor
            } else {
                backgroundColor = highlightBackgroundColor
            }
        }
    }
    
    // old background holds background color before highlight state change
    private var oldBackground: UIColor? = nil
    public var isHighlighted: Bool = false {
        didSet {
            if oldBackground == nil {
                return
            }
            if isHighlighted != oldValue {
                let switchBackgroundColor = oldBackground
                oldBackground = backgroundColor
                UIView.animate(withDuration: isHighlighted ? 0.1 : 0.5,
                               delay: 0,
                               options: UIView.AnimationOptions.allowUserInteraction) {
                    self.backgroundColor = switchBackgroundColor
                }
            }
        }
    }

    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        isHighlighted = true
    }

    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isHighlighted = false
    }

    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        isHighlighted = false
    }
}
