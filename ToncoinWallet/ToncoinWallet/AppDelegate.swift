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

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        
        window?.backgroundColor = WTheme.background
        
        // StartVC for users who are using the app for the first time
        let startVC = SplashVC(nibName: "SplashVC", bundle: Bundle.main)
        let navigationController = UINavigationController(rootViewController: startVC)
        self.window?.rootViewController = navigationController
        
        self.window?.makeKeyAndVisible()
        
        return true
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {

        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
          let url = userActivity.webpageURL,
          let components = URLComponents(url: url,
                                         resolvingAgainstBaseURL: true) else {
            return false
        }

        return true
    }
}
