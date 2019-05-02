//
//  CarbonSinkPhotosNavigationController.swift
//  EcoDatumIOSApp
//
//  Created by Kenneth Wingerden on 5/2/19.
//  Copyright © 2019 Kenneth Wingerden. All rights reserved.
//

import CoreData
import EcoDatumCoreData
import EcoDatumService
import Foundation
import UIKit

class CarbonSinkPhotosNavigationController: UINavigationController, CoreDataContextHolder, SiteEntityHolder  {
    
    var context: NSManagedObjectContext!
    
    var site: SiteEntity!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for vc in viewControllers {
            if var holder = vc as? CoreDataContextHolder {
                holder.context = context
            }
            if var holder = vc as? SiteEntityHolder {
                holder.site = site
            }
        }
    }
    
}
