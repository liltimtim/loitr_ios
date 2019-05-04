//
//  AppDelegate.swift
//  Loitr
//
//  Created by Timothy Dillman on 5/2/19.
//  Copyright © 2019 Timothy Dillman. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        if (launchOptions?.contains(where: { return $0.key == .location }) ?? false) {
//            let location = launchOptions[UIApplication.LaunchOptionsKey.location]
//            LocationProvider.didLaunch(with: l)
            let _ = LocationProvider.instance
        }
        window = UIWindow(frame: UIScreen.main.bounds)
        let vc = LoitrSummaryViewController()
//        let vc = MainViewController()
        window?.rootViewController = vc
        return true
    }

}

