//
//  MainNavigationController.swift
//  EcoDatumIOSApp
//
//  Created by Kenneth Wingerden on 3/26/19.
//  Copyright © 2019 Kenneth Wingerden. All rights reserved.
//

import CoreData
import Foundation
import UIKit

class NotebookMasterController: UINavigationController, CoreDataContextHolder {
    
    var context: NSManagedObjectContext! {
        willSet {
            log.debug("will set")
            for child in self.children {
                if var holder = child as? CoreDataContextHolder {
                    holder.context = newValue
                } else {
                    log.warning("UIViewController \(child) not a CoreDataContextHolder")
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        log.debug("viewDidLoad()")
    }
    
}
