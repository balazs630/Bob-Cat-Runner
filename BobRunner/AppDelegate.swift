//
//  AppDelegate.swift
//  BobRunner
//
//  Created by Horváth Balázs on 2017. 05. 22..
//  Copyright © 2017. Horváth Balázs. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let defaults = UserDefaults.standard
        
        if defaults.object(forKey: UserDefaults.Key.isAppAlreadyLaunchedOnce) == nil {
            let firstTimeLaunchDefaults: [String : Any] = [
                UserDefaults.Key.isAppAlreadyLaunchedOnce: true,
                UserDefaults.Key.actualStage: 1
            ]
            
            for item in firstTimeLaunchDefaults {
                defaults.set(item.value, forKey: item.key)
            }
            
            defaults.synchronize()
        }
        
        return true
    }
    
}
