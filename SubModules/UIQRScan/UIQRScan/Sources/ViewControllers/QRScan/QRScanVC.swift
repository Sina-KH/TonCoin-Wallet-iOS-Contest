//
//  QRScanVC.swift
//  UIQRScan
//
//  Created by Sina on 5/13/23.
//

import UIKit
import UIComponents
import WalletContext
import WalletCore
import SwiftSignalKit
import WalletUrl

public class QRScanVC: WViewController {
    
    // MARK: - Initializer
    private let walletContext: WalletContext
    private let walletInfo: WalletInfo
    private let callback: ((_ url: URL) -> Void)
    public init(walletContext: WalletContext, walletInfo: WalletInfo, callback: @escaping ((_ url: URL) -> Void)) {
        self.walletContext = walletContext
        self.walletInfo = walletInfo
        self.callback = callback
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        self.codeDisposable?.dispose()
        self.inForegroundDisposable?.dispose()
    }

    public override func loadView() {
        super.loadView()
        setupViews()
    }

    private var noAccessView: NoCameraAccessView? = nil
    private var qrScanView: QRScanView? = nil
    
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    private func setupViews() {
        view.backgroundColor = .black
        
        // navigation bar
        let backItem = WNavigationBarButton(text: WStrings.Wallet_Navigation_Back.localized,
                                            icon: UIImage(named: "LeftIcon")!.withRenderingMode(.alwaysTemplate),
                                            onPress: { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        })
        let navigationBar = WNavigationBar(leadingItem: backItem)
        navigationBar.tintColor = .white
        view.addSubview(navigationBar)
        NSLayoutConstraint.activate([
            navigationBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            navigationBar.leftAnchor.constraint(equalTo: view.leftAnchor),
            navigationBar.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])

        authorizeAccessToCamera()
    }
        
    private func authorizeAccessToCamera() {
        walletContext.authorizeAccessToCamera(completion: { [weak self] granted in
            guard let self else {
                return
            }
            if granted {
                showScanView()
            } else {
                showNoAccessView()
            }
        })
    }
    
    private var codeDisposable: Disposable?
    private var inForegroundDisposable: Disposable?

    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.inForegroundDisposable = (walletContext.inForeground
        |> deliverOnMainQueue).start(next: { [weak self] inForeground in
            guard let strongSelf = self else {
                return
            }
            strongSelf.qrScanView?.updateInForeground(inForeground)
        })
    }

    private func showScanView() {
        noAccessView?.removeFromSuperview()

        qrScanView = QRScanView(presentGallery: { [weak self] in
            guard let self else {
                return
            }
            walletContext.pickImage(completion: { [weak self] image in
                guard let self else {
                    return
                }
                let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])!
                if let ciImage = CIImage(image: image) {
                    var options: [String: Any]
                    if ciImage.properties.keys.contains((kCGImagePropertyOrientation as String)) {
                        options = [CIDetectorImageOrientation: ciImage.properties[(kCGImagePropertyOrientation as String)] ?? 1]
                    } else {
                        options = [CIDetectorImageOrientation: 1]
                    }
                    
                    let features = detector.features(in: ciImage, options: options)
                    for case let row as CIQRCodeFeature in features {
                        guard let message = row.messageString else {
                            continue
                        }
                        if let url = URL(string: message), let _ = parseWalletUrl(url) {
                            navigationController?.popViewController(animated: true, completion: {
                                self.callback(url)
                            })
                            return
                        }
                    }
                }
                showAlert(title: nil, text: WStrings.Wallet_QRScan_NoValidQRDetected.localized,
                          button: WStrings.Wallet_Alert_OK.localized)
            })
        
        })
        qrScanView?.translatesAutoresizingMaskIntoConstraints = false

        view.insertSubview(qrScanView!, at: 0)
        NSLayoutConstraint.activate([
            qrScanView!.leftAnchor.constraint(equalTo: view.leftAnchor),
            qrScanView!.rightAnchor.constraint(equalTo: view.rightAnchor),
            qrScanView!.topAnchor.constraint(equalTo: view.topAnchor),
            qrScanView!.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        self.codeDisposable = (qrScanView!.focusedCode.get()
        |> map { code -> String? in
            return code?.message
        }
        |> distinctUntilChanged
        |> mapToSignal { code -> Signal<String?, NoError> in
            return .single(code) |> delay(0.5, queue: Queue.mainQueue())
        }).start(next: { [weak self] code in
            guard let self, let code = code else {
                return
            }
            if let url = URL(string: code) {
                self.callback(url)
                navigationController?.popViewController(animated: true)
            }
        })
    }
    
    private func showNoAccessView() {
        if noAccessView == nil {
            noAccessView = NoCameraAccessView()
        }
        if noAccessView?.superview == nil {
            view.insertSubview(noAccessView!, at: 0)
            NSLayoutConstraint.activate([
                noAccessView!.leftAnchor.constraint(equalTo: view.leftAnchor),
                noAccessView!.rightAnchor.constraint(equalTo: view.rightAnchor),
                noAccessView!.topAnchor.constraint(equalTo: view.topAnchor),
                noAccessView!.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        }
    }
    
}
