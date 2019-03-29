//
//  NotebookDetailNavigationController.swift
//  EcoDatumIOSApp
//
//  Created by Kenneth Wingerden on 3/28/19.
//  Copyright © 2019 Kenneth Wingerden. All rights reserved.
//

import CoreData
import Foundation
import UIKit

class NotebookDetailNavigationController: UINavigationController, CoreDataContextHolder {
    
    var context: NSManagedObjectContext! {
        willSet {
            log.debug("will set")
            for child in self.children {
                var holder = child as! CoreDataContextHolder
                holder.context = newValue
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        log.debug("viewDidLoad()")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(notebookSelected(_:)),
                                               name: .notebookSelected,
                                               object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func notebookSelected(_ notification: Notification) {
        guard notification.name == .notebookSelected else {
            log.error("Unexpected Notebook notification: \(notification)")
            return
        }
        
        guard let data = notification.userInfo as? [String: String],
            let name = data["name"] else {
                log.error("Failed to get Notebook name from notification: \(notification)")
                return
        }
        
        navigationBar.topItem?.title = name
    }

}
