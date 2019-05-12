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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        log.addDestination(ConsoleDestination())
        
        if let coreDataManager = CoreDataManager("EcoDatum")  {
            let context = coreDataManager.mainContext
            do {
                let notebook = try NotebookEntity.new(context)
                try notebook.save()
            } catch NotebookEntity.EntityError.NameAlreadyExists(let name) {
                log.debug("Notebook \(name) already exists")
            } catch let error as NSError {
                log.error("Failed to create \(NotebookEntity.DEFAULT_NOTEBOOK_NAME) Notebook: \(error)")
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
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return true
    }
    
}

