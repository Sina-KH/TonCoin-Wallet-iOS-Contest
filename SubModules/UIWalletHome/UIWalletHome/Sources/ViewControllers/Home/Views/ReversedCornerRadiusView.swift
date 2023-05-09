//
//  ReversedCornerRadiusView.swift
//  UIWalletHome
//
//  Created by Sina on 5/4/23.
//

import UIKit

class ReversedCornerRadiusView: UIView {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // reversed corner radius on bottom
        let width = frame.width
        let rectShape = CAShapeLayer()
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 16, y: 0))
        path.addArc(withCenter: CGPoint(x: 16, y: 16),
                    radius: 16,
                    startAngle: .pi * 3 / 2,
                    endAngle: .pi,
                    clockwise: false)
        path.addLine(to: CGPoint(x: width, y: 16))
        path.addArc(withCenter: CGPoint(x: width - 16, y: 16),
                    radius: 16,
                    startAngle: 0,
                    endAngle: .pi * 3 / 2,
                    clockwise: false)
        path.addLine(to: CGPoint(x: 16, y: 0))
        path.close()
        
        let p = CGMutablePath()
        p.addRect(bounds)
        p.addPath(path.cgPath)
        rectShape.path = p

        layer.mask = rectShape
    }
    
}
