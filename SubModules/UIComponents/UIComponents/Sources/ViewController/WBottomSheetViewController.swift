//
//  WBottomSheetViewController.swift
//  UIComponents
//
//  Created by Sina on 4/29/23.
//

import UIKit

public class WBottomSheetViewController: WViewController {

    private let contentViewController: UIViewController
    private weak var delegate: WViewController?
    public init(contentViewController: UIViewController, delegate: WViewController) {
        self.contentViewController = contentViewController
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        delegate?.modalWillDisappear()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        delegate?.modalWillAppear()
    }

    private var contentBottomConstraint: NSLayoutConstraint!

    public override func loadView() {
        super.loadView()

        view.backgroundColor = .clear
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewPressed)))

        // setup content view controller
        contentViewController.view.translatesAutoresizingMaskIntoConstraints = false
        contentViewController.view.layer.cornerRadius = 10
        contentViewController.view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        view.addSubview(contentViewController.view)
        contentBottomConstraint = contentViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        NSLayoutConstraint.activate([
            contentViewController.view.leftAnchor.constraint(equalTo: view.leftAnchor),
            contentViewController.view.rightAnchor.constraint(equalTo: view.rightAnchor),
            contentBottomConstraint
        ])
        addChild(contentViewController)
        contentViewController.didMove(toParent: self)
    }
    
    @objc func viewPressed(sender: UITapGestureRecognizer) {
        // dismiss only if outside of the content tapped
        let location = sender.location(in: view)
        if let view = self.view.hitTest(location, with: nil), let guester = view.gestureRecognizers {
            if guester.contains(sender) {
                dismiss(animated: true)
            }
        }
    }

}
