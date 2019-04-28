//
//  MainNavigationWindow.swift
//  EcoDatumIOSApp
//
//  Created by Kenneth Wingerden on 4/28/19.
//  Copyright © 2019 Kenneth Wingerden. All rights reserved.
//

import CoreData
import Foundation
import UIKit

class MainNavigationController: UINavigationController, CoreDataContextHolder {
    
    var context: NSManagedObjectContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for vc in viewControllers {
            if var holder = vc as? CoreDataContextHolder {
                holder.context = context
            } else {
                log.warning("UIViewController \(vc) is not a CoreDataContextHolder")
            }
        }
    }
    
}
