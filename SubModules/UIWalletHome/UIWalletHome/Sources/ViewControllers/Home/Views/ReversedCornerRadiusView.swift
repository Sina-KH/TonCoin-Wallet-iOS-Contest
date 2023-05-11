//
//  ReversedCornerRadiusView.swift
//  UIWalletHome
//
//  Created by Sina on 5/4/23.
//

import UIKit

fileprivate let _radius = CGFloat(10)

public class ReversedCornerRadiusView: UIView {
    
    public static let radius = _radius
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        // reversed corner radius on bottom
        let width = frame.width
        let rectShape = CAShapeLayer()
        let path = UIBezierPath()
        path.move(to: CGPoint(x: _radius, y: 0))
        path.addArc(withCenter: CGPoint(x: _radius, y: _radius),
                    radius: _radius,
                    startAngle: .pi * 3 / 2,
                    endAngle: .pi,
                    clockwise: false)
        path.addLine(to: CGPoint(x: width, y: _radius))
        path.addArc(withCenter: CGPoint(x: width - _radius, y: _radius),
                    radius: _radius,
                    startAngle: 0,
                    endAngle: .pi * 3 / 2,
                    clockwise: false)
        path.addLine(to: CGPoint(x: _radius, y: 0))
        path.close()
        
        let p = CGMutablePath()
        p.addRect(bounds)
        p.addPath(path.cgPath)
        rectShape.path = p

        layer.mask = rectShape
    }
    
}
