//
//  AppDelegate.swift
//  EcoDatumIOSApp
//
//  Created by Kenneth Wingerden on 3/11/19.
//  Copyright © 2019 Kenneth Wingerden. All rights reserved.
//

import CoreData
import EcoDatumCoreData
import EcoDatumService
import SwiftyBeaver
import UIKit

let log = SwiftyBeaver.self

let DEFAULT_NOTEBOOK_NAME = "Default"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        log.addDestination(ConsoleDestination())
        
        if let coreDataManager = CoreDataManager("EcoDatum")  {
            let context = coreDataManager.mainContext
            do {
                if try !NotebookEntity.exists(context, with: DEFAULT_NOTEBOOK_NAME) {
                    let context = coreDataManager.mainContext
                    let notebook = NotebookEntity.new(context)
                    try notebook.save()
                }
            } catch let error as NSError {
                log.error("Failed to create \(DEFAULT_NOTEBOOK_NAME) Notebook: \(error)")
            }
            
            if var vc = window?.rootViewController as? CoreDataContextHolder {
                vc.context = context
            }
        } else {
            log.error("Failed to instantiate CoreDataManager")
            return false
        }
            
        return true
    }
    
}

