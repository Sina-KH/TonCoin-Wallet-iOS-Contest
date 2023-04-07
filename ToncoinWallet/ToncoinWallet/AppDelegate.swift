//
//  AppDelegate.swift
//  ToncoinWallet
//
//  Created by Sina on 3/30/23.
//

import UIKit
import UICreateWallet

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.window = UIWindow(frame: UIScreen.main.bounds)

        // StartVC for users who are using the app for the first time
        let startVC = StartVC(nibName: "StartVC", bundle: Bundle(identifier: "org.ton.wallet.UICreateWallet"))
        let navigationController = UINavigationController(rootViewController: startVC)
        self.window?.rootViewController = navigationController

        self.window?.makeKeyAndVisible()
        return true
    }

}
