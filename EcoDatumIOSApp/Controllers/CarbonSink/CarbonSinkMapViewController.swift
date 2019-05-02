//
//  CarbonSinkMapViewController.swift
//  EcoDatumIOSApp
//
//  Created by Kenneth Wingerden on 5/1/19.
//  Copyright © 2019 Kenneth Wingerden. All rights reserved.
//

import CoreData
import EcoDatumCoreData
import EcoDatumService
import Foundation
import UIKit

class CarbonSinkMapViewController: UIViewController, CoreDataContextHolder, SiteEntityHolder  {
    
    var context: NSManagedObjectContext!
    
    var site: SiteEntity!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "\(site.name!) - Map"
    }
    
}
