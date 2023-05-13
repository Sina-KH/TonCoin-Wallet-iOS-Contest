//
//  QRScanView.swift
//  UIQRScan
//
//  Created by Sina on 5/14/23.
//

import UIKit
import UIComponents
import WalletContext
import SwiftSignalKit
import QuartzCore

class QRScanView: UIView, UIScrollViewDelegate {

    private var previewNode: CameraPreviewNode!
    private var focusView: UIView!
    // focus view constraints that hold it center of the screen, filled if no focused rect found
    private var focusViewConstraints: [NSLayoutConstraint]!
    // focus view constraints after qr code found
    private var focusViewLeftConstraint: NSLayoutConstraint? = nil
    private var focusViewTopConstraint: NSLayoutConstraint? = nil
    private var focusViewWidthConstraint: NSLayoutConstraint? = nil
    private var focusViewHeightConstraint: NSLayoutConstraint? = nil
    //    private let galleryButtonNode: GlassButtonNode
    //    private let torchButtonNode: GlassButtonNode
    private var titleNode: UILabel!
    
    private var camera: Camera!
    private let codeDisposable = MetaDisposable()
    
    let focusedCode = ValuePromise<CameraCode?>(ignoreRepeated: true)
    
    var presentGallery: (() -> Void)?
    
    init() {
        super.init(frame: .zero)
        setupViews()
        setupCamera()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        self.codeDisposable.dispose()
        self.camera.stopCapture(invalidate: true)
    }
    
    func updateInForeground(_ inForeground: Bool) {
        if !inForeground {
            self.camera.stopCapture(invalidate: false)
        } else {
            self.camera.startCapture()
        }
    }
    
    private func defaultFocusAreaConstraints() -> [NSLayoutConstraint] {
        return [
            focusView.widthAnchor.constraint(equalToConstant: 260),
            focusView.heightAnchor.constraint(equalToConstant: 260),
            focusView.centerXAnchor.constraint(equalTo: centerXAnchor),
            focusView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ]
    }
    
    private func setupViews() {
        previewNode = CameraPreviewNode()
        previewNode.translatesAutoresizingMaskIntoConstraints = false
        previewNode.backgroundColor = .black
        addSubview(previewNode)
        NSLayoutConstraint.activate([
            previewNode.leftAnchor.constraint(equalTo: leftAnchor),
            previewNode.rightAnchor.constraint(equalTo: rightAnchor),
            previewNode.topAnchor.constraint(equalTo: topAnchor),
            previewNode.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        focusView = UIView()
        focusView.translatesAutoresizingMaskIntoConstraints = false
        focusView.backgroundColor = .clear
        addSubview(focusView)
        focusViewConstraints = defaultFocusAreaConstraints()
        NSLayoutConstraint.activate(focusViewConstraints)
        
        let topDimNode = UIView()
        topDimNode.translatesAutoresizingMaskIntoConstraints = false
        topDimNode.alpha = 0.625
        topDimNode.backgroundColor = .black.withAlphaComponent(0.8)
        addSubview(topDimNode)
        NSLayoutConstraint.activate([
            topDimNode.leftAnchor.constraint(equalTo: leftAnchor),
            topDimNode.rightAnchor.constraint(equalTo: rightAnchor),
            topDimNode.topAnchor.constraint(equalTo: topAnchor),
            topDimNode.bottomAnchor.constraint(equalTo: focusView.topAnchor)
        ])
        
        let bottomDimNode = UIView()
        bottomDimNode.translatesAutoresizingMaskIntoConstraints = false
        bottomDimNode.alpha = 0.625
        bottomDimNode.backgroundColor = .black.withAlphaComponent(0.8)
        addSubview(bottomDimNode)
        NSLayoutConstraint.activate([
            bottomDimNode.leftAnchor.constraint(equalTo: leftAnchor),
            bottomDimNode.rightAnchor.constraint(equalTo: rightAnchor),
            bottomDimNode.topAnchor.constraint(equalTo: focusView.bottomAnchor),
            bottomDimNode.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        let leftDimNode = UIView()
        leftDimNode.translatesAutoresizingMaskIntoConstraints = false
        leftDimNode.alpha = 0.625
        leftDimNode.backgroundColor = .black.withAlphaComponent(0.8)
        addSubview(leftDimNode)
        NSLayoutConstraint.activate([
            leftDimNode.leftAnchor.constraint(equalTo: leftAnchor),
            leftDimNode.rightAnchor.constraint(equalTo: focusView.leftAnchor),
            leftDimNode.topAnchor.constraint(equalTo: focusView.topAnchor),
            leftDimNode.bottomAnchor.constraint(equalTo: focusView.bottomAnchor)
        ])
        
        let rightDimNode = UIView()
        rightDimNode.translatesAutoresizingMaskIntoConstraints = false
        rightDimNode.alpha = 0.625
        rightDimNode.backgroundColor = .black.withAlphaComponent(0.8)
        addSubview(rightDimNode)
        NSLayoutConstraint.activate([
            rightDimNode.leftAnchor.constraint(equalTo: focusView.rightAnchor),
            rightDimNode.rightAnchor.constraint(equalTo: rightAnchor),
            rightDimNode.topAnchor.constraint(equalTo: focusView.topAnchor),
            rightDimNode.bottomAnchor.constraint(equalTo: focusView.bottomAnchor)
        ])

        let frameNode = UIImageView()
        frameNode.translatesAutoresizingMaskIntoConstraints = false
        frameNode.image = generateFrameImage()
        addSubview(frameNode)
        NSLayoutConstraint.activate([
            frameNode.leftAnchor.constraint(equalTo: focusView.leftAnchor, constant: -2),
            frameNode.rightAnchor.constraint(equalTo: focusView.rightAnchor, constant: 2),
            frameNode.topAnchor.constraint(equalTo: focusView.topAnchor, constant: -2),
            frameNode.bottomAnchor.constraint(equalTo: focusView.bottomAnchor, constant: 2)
        ])
        
        //        self.galleryButtonNode = GlassButtonNode(icon: UIImage(bundleImageName: "Wallet/CameraGalleryIcon")!, label: nil)
        //        self.torchButtonNode = GlassButtonNode(icon: UIImage(bundleImageName: "Wallet/CameraFlashIcon")!, label: nil)
        
        titleNode = UILabel()
        titleNode.translatesAutoresizingMaskIntoConstraints = false
        titleNode.font = .systemFont(ofSize: 28, weight: .semibold)
        titleNode.textColor = .white
        titleNode.text = WStrings.Wallet_QRScan_Title.localized
        addSubview(titleNode)
        NSLayoutConstraint.activate([
            titleNode.bottomAnchor.constraint(equalTo: focusView.topAnchor, constant: -44),
            titleNode.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
        
        self.camera = Camera(configuration: .init(preset: .hd1920x1080, position: .back, audio: false))
        
        //        self.addSubview(self.galleryButtonNode)
        //        self.addSubview(self.torchButtonNode)
        
        //        self.galleryButtonNode.addTarget(self, action: #selector(self.galleryPressed), forControlEvents: .touchUpInside)
        //        self.torchButtonNode.addTarget(self, action: #selector(self.torchPressed), forControlEvents: .touchUpInside)
        
    }
    
    private func setupCamera() {
        self.camera.attachPreviewNode(previewNode)
        self.camera.startCapture()
        
        let throttledSignal = self.camera.detectedCodes
        |> mapToThrottled { next -> Signal<[CameraCode], NoError> in
            return .single(next) |> then(.complete() |> delay(0.3, queue: Queue.concurrentDefaultQueue()))
        }
        
        self.codeDisposable.set((throttledSignal
                                 |> deliverOnMainQueue).start(next: { [weak self] codes in
            guard let strongSelf = self else {
                return
            }
            let filteredCodes = codes.filter { $0.message.hasPrefix("ton://") }
            if let code = filteredCodes.first, CGRect(x: 0.3, y: 0.3, width: 0.4, height: 0.4).contains(code.boundingBox.center) {
                strongSelf.focusedCode.set(code)
                strongSelf.updateFocusedRect(code.boundingBox)
            } else {
                strongSelf.focusedCode.set(nil)
                strongSelf.updateFocusedRect(nil)
            }
        }))
    }
    
    // MARK: - Called when focused rect change
    private func updateFocusedRect(_ rect: CGRect?) {

        if let rect {
            // found a focus
            let side = max(bounds.width * rect.width, bounds.height * rect.height) * 0.6
            let center = CGPoint(x: (1.0 - rect.center.y) * bounds.width, y: rect.center.x * bounds.height)
            let focusedRect = CGRect(x: center.x - side / 2.0, y: center.y - side / 2.0, width: side, height: side)
            
            if !focusViewConstraints.isEmpty {
                // first time focus rect found, disable default constraints and set frame constraints
                UIView.animate(withDuration: 0.4) { [weak self] in
                    guard let self else {
                        return
                    }
                    NSLayoutConstraint.deactivate(focusViewConstraints)
                    focusViewConstraints = []
                    focusViewLeftConstraint = focusView.leftAnchor.constraint(equalTo: leftAnchor, constant: focusedRect.minX)
                    focusViewTopConstraint = focusView.topAnchor.constraint(equalTo: topAnchor, constant: focusedRect.minY)
                    focusViewWidthConstraint = focusView.widthAnchor.constraint(equalToConstant: focusedRect.width)
                    focusViewHeightConstraint = focusView.heightAnchor.constraint(equalToConstant: focusedRect.height)
                    NSLayoutConstraint.activate([
                        focusViewLeftConstraint!,
                        focusViewTopConstraint!,
                        focusViewWidthConstraint!,
                        focusViewHeightConstraint!
                    ])
                    layoutIfNeeded()
                }
            } else {
                // update focus rect constraints
                UIView.animate(withDuration: 0.2) { [weak self] in
                    guard let self else {
                        return
                    }
                    focusViewLeftConstraint!.constant = focusedRect.minX
                    focusViewTopConstraint!.constant = focusedRect.minY
                    focusViewWidthConstraint!.constant = focusedRect.width
                    focusViewHeightConstraint!.constant = focusedRect.height
                    layoutIfNeeded()
                }
            }
        } else {
            // was on focused area, reset
            if focusViewConstraints.isEmpty {
                focusViewConstraints = defaultFocusAreaConstraints()

                // update focus rect
                UIView.animate(withDuration: 0.2) { [weak self] in
                    guard let self else {
                        return
                    }
                    NSLayoutConstraint.deactivate([
                        focusViewLeftConstraint!,
                        focusViewTopConstraint!,
                        focusViewWidthConstraint!,
                        focusViewHeightConstraint!
                    ])
                    NSLayoutConstraint.activate(focusViewConstraints)
                    layoutIfNeeded()
                }
            }
        }
    }

}

// MARK: - Generate a frame for focused area
private func generateFrameImage() -> UIImage? {
    return generateImage(CGSize(width: 64.0, height: 64.0), contextGenerator: { size, context in
        let bounds = CGRect(origin: CGPoint(), size: size)
        context.clear(bounds)
        context.setStrokeColor(UIColor.white.cgColor)
        context.setLineWidth(4.0)
        context.setLineCap(.round)
        
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 2.0, y: 2.0 + 26.0))
        path.addArc(tangent1End: CGPoint(x: 2.0, y: 2.0), tangent2End: CGPoint(x: 2.0 + 26.0, y: 2.0), radius: 6.0)
        path.addLine(to: CGPoint(x: 2.0 + 26.0, y: 2.0))
        context.addPath(path)
        context.strokePath()
        
        path.move(to: CGPoint(x: size.width - 2.0, y: 2.0 + 26.0))
        path.addArc(tangent1End: CGPoint(x: size.width - 2.0, y: 2.0), tangent2End: CGPoint(x: 2.0 + 26.0, y: 2.0), radius: 6.0)
        path.addLine(to: CGPoint(x: size.width - 2.0 - 26.0, y: 2.0))
        context.addPath(path)
        context.strokePath()
        
        path.move(to: CGPoint(x: 2.0, y: size.height - 2.0 - 26.0))
        path.addArc(tangent1End: CGPoint(x: 2.0, y: size.height - 2.0), tangent2End: CGPoint(x: 2.0 + 26.0, y: size.height - 2.0), radius: 6.0)
        path.addLine(to: CGPoint(x: 2.0 + 26.0, y: size.height - 2.0))
        context.addPath(path)
        context.strokePath()
        
        path.move(to: CGPoint(x: size.width - 2.0, y: size.height - 2.0 - 26.0))
        path.addArc(tangent1End: CGPoint(x: size.width - 2.0, y: size.height - 2.0), tangent2End: CGPoint(x: 2.0 + 26.0, y: size.height - 2.0), radius: 6.0)
        path.addLine(to: CGPoint(x: size.width - 2.0 - 26.0, y: size.height - 2.0))
        context.addPath(path)
        context.strokePath()
    })?.stretchableImage(withLeftCapWidth: 32, topCapHeight: 32)
}
