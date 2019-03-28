//
//  MainViewController.swift
//  EcoDatumIOSApp
//
//  Created by Kenneth Wingerden on 3/26/19.
//  Copyright © 2019 Kenneth Wingerden. All rights reserved.
//

import CoreData
import Foundation
import UIKit

class NotebookDetailViewController: UIViewController, CoreDataContextHolder {
        
    var context: NSManagedObjectContext! {
        didSet {
            log.debug("did set")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        log.debug("viewDidLoad()")
    }
    
}
