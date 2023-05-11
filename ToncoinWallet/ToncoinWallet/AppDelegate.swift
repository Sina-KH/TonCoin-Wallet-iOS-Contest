//
//  AppDelegate.swift
//  ToncoinWallet
//
//  Created by Sina on 3/30/23.
//

import UIKit
import WalletContext

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var deeplinkHandler: DeeplinkHandler? = nil

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        
        window?.backgroundColor = WTheme.background
        
        // StartVC for users who are using the app for the first time
        let startVC = SplashVC(nibName: "SplashVC", bundle: Bundle.main)
        let navigationController = UINavigationController(rootViewController: startVC)
        self.window?.rootViewController = navigationController
        
        self.window?.makeKeyAndVisible()
        
        deeplinkHandler = DeeplinkHandler(deeplinkNavigator: startVC)

        return true
    }
    // handle `ton://` for `toncoin invoices` and `tc://` for `ton connect` deeplinks
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        deeplinkHandler?.handle(url)
        return true
    }
    
    func application(_ application: UIApplication,
                     continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {

        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
              let url = userActivity.webpageURL else {
            return false
        }

        deeplinkHandler?.handle(url)

        return true
    }
}
