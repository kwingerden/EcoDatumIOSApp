//
//  MainSplitViewController.swift
//  EcoDatumIOSApp
//
//  Created by Kenneth Wingerden on 3/26/19.
//  Copyright © 2019 Kenneth Wingerden. All rights reserved.
//

import CoreData
import Foundation
import UIKit

class NotebookSplitViewController: UISplitViewController, CoreDataContextHolder {
   
    var context: NSManagedObjectContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        log.debug("viewDidLoad()")
        
        delegate = self
        preferredDisplayMode = .allVisible
        
        for vc in viewControllers {
            var holder = vc as! CoreDataContextHolder
            holder.context = context
        }
    }
    
}

extension NotebookSplitViewController: UISplitViewControllerDelegate {
    
    func splitViewController(
        _ splitViewController: UISplitViewController,
        collapseSecondary secondaryViewController: UIViewController,
        onto primaryViewController: UIViewController) -> Bool {
        // Return true to prevent UIKit from applying its default behavior
        return true
    }
    
}
