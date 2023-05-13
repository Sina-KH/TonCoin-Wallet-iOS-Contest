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
        navigationController?.setNavigationBarHidden(false, animated: false)

        view.backgroundColor = .black
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

        qrScanView = QRScanView()
        qrScanView?.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(qrScanView!)
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
            view.addSubview(noAccessView!)
            NSLayoutConstraint.activate([
                noAccessView!.leftAnchor.constraint(equalTo: view.leftAnchor),
                noAccessView!.rightAnchor.constraint(equalTo: view.rightAnchor),
                noAccessView!.topAnchor.constraint(equalTo: view.topAnchor),
                noAccessView!.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        }
    }
    
}
