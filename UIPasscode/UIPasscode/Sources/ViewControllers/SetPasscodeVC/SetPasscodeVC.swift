//
//  SetPasscodeVC.swift
//  UIPasscode
//
//  Created by Sina on 4/16/23.
//

import UIKit
import UIComponents
import WalletContext

public class SetPasscodeVC: WViewController {

    var headerView: HeaderView!
    var passcodeInputView: PasscodeInputView!

    public init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func loadView() {
        super.loadView()
        setupViews()
    }
    
    func setupViews() {
        // top animation and header
        let topView = UIView()
        topView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(topView)
        NSLayoutConstraint.activate([
            topView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            topView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            topView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor)
        ])

        headerView = HeaderView(animationName: "Password",
                                    animationWidth: 124, animationHeight: 124,
                                    animationPlaybackMode: .toggle(false),
                                    title: WStrings.Wallet_SetPasscode_Title.localized,
                                    description: WStrings.Wallet_SetPasscode_Text.localized)
        topView.addSubview(headerView)
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: topView.topAnchor, constant: 46),
            headerView.centerXAnchor.constraint(equalTo: topView.centerXAnchor),
            headerView.bottomAnchor.constraint(equalTo: topView.bottomAnchor)
        ])

        // setup passcode input view
        passcodeInputView = PasscodeInputView(delegate: self)
        passcodeInputView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(passcodeInputView)
        NSLayoutConstraint.activate([
            passcodeInputView.topAnchor.constraint(equalTo: topView.bottomAnchor, constant: 40),
            passcodeInputView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        passcodeInputView.becomeFirstResponder()
        
        // setup passcode options button
        
    }

}

extension SetPasscodeVC: PasscodeInputViewDelegate {
    func passcodeChanged(passcode: String) {
        headerView.animatedSticker.toggle(!passcode.isEmpty)
    }
    func passcodeSelected(passcode: String) {
        
    }
}
