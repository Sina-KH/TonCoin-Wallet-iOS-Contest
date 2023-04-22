//
//  QRCodeContainerView.swift
//  UIWalletHome
//
//  Created by Sina on 4/22/23.
//

import UIKit
import UIComponents
import WalletContext

public protocol QRCodeContainerViewDelegate: AnyObject {
    func qrCodePressed()
}

public class QRCodeContainerView: UIView {
        
    private var url: String!
    private weak var delegate: QRCodeContainerViewDelegate!
    public init(url: String, size: CGFloat, delegate: QRCodeContainerViewDelegate) {
        self.url = url
        self.delegate = delegate
        super.init(frame: CGRect.zero)
        setupView(size: size)
    }

    override public init(frame: CGRect) {
        fatalError()
    }
    
    required public init?(coder: NSCoder) {
        fatalError()
    }

    private func setupView(size: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            //qrCodeContainer.widthAnchor.constraint(equalToConstant: 220),
            heightAnchor.constraint(equalToConstant: size)
        ])
        // qr code image
        let qrCode = WQrCode(url: url, width: size, height: size)
        qrCode.translatesAutoresizingMaskIntoConstraints = false
        addSubview(qrCode)
        NSLayoutConstraint.activate([
            qrCode.widthAnchor.constraint(equalToConstant: size),
            qrCode.heightAnchor.constraint(equalToConstant: size),
            qrCode.centerXAnchor.constraint(equalTo: centerXAnchor),
            qrCode.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        // qr code animation
        let qrCodeAnimatedIcon = WAnimatedSticker()
        qrCodeAnimatedIcon.translatesAutoresizingMaskIntoConstraints = false
        qrCodeAnimatedIcon.animationName = "Start"
        qrCodeAnimatedIcon.setup(width: 50, height: 50,
                                 playbackMode: .loop)
        addSubview(qrCodeAnimatedIcon)
        NSLayoutConstraint.activate([
            qrCodeAnimatedIcon.widthAnchor.constraint(equalToConstant: 50),
            qrCodeAnimatedIcon.heightAnchor.constraint(equalToConstant: 50),
            qrCodeAnimatedIcon.centerXAnchor.constraint(equalTo: centerXAnchor),
            qrCodeAnimatedIcon.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveLinear, animations: {
                self.alpha = 0.4
            }, completion: nil)
        }
    }

    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveLinear, animations: {
                self.alpha = 1.0
            }, completion: {_ in
                self.delegate.qrCodePressed()
            })
        }
    }

    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveLinear, animations: {
                self.alpha = 1.0
            }, completion: nil)
        }
    }
}
