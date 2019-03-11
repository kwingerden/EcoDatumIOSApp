//
//  AppDelegate.swift
//  EcoDatumIOSApp
//
//  Created by Kenneth Wingerden on 3/11/19.
//  Copyright © 2019 Kenneth Wingerden. All rights reserved.
//

import EcoDatumCoreData
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        try! CoreDataManager.shared.reset()
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let storyboard = UIStoryboard.init(name: "TestLocation", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "TestLocationController") as! TestLocationController
        self.window?.rootViewController = viewController
        self.window?.makeKeyAndVisible()
        
        return true
    }
    
}

