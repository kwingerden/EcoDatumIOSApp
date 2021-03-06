//
//  CarbonSinkDetailViewController.swift
//  EcoDatumIOSApp
//
//  Created by Kenneth Wingerden on 4/29/19.
//  Copyright © 2019 Kenneth Wingerden. All rights reserved.
//

import CoreData
import EcoDatumCoreData
import EcoDatumService
import Foundation
import UIKit

class CarbonSinkDetailTabBarController: UITabBarController, CoreDataContextHolder, SiteEntityHolder {
    
    var context: NSManagedObjectContext!
    
    var site: SiteEntity!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "\(site.name!) - Photos"
        viewControllers?.forEach { vc in
            if var holder = vc as? CoreDataContextHolder {
                holder.context = self.context
            }
            if var holder = vc as? SiteEntityHolder {
                holder.site = self.site
            }
        }
    }
    
}
