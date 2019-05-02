//
//  CarbonSinkDetailViewController.swift
//  EcoDatumIOSApp
//
//  Created by Kenneth Wingerden on 4/29/19.
//  Copyright © 2019 Kenneth Wingerden. All rights reserved.
//

import EcoDatumCoreData
import EcoDatumModel
import Foundation
import UIKit

class CarbonSinkDetailTabBarController: UITabBarController, SiteEntityHolder {
    
    var site: SiteEntity!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "\(site.name!) - Photo"
        viewControllers?.forEach { vc in
            if var siteEntityHolder = vc as? SiteEntityHolder {
                siteEntityHolder.site = self.site
            }
        }
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        switch item.title! {
        case "Photo":
            title = "\(site.name!) - Photo"
        case "Map":
            title = "\(site.name!) - Map"
        case "Data":
            title = "\(site.name!) - Data"
        default:
            log.error("Unknown tab bar item: \(item.title!)")
        }
    }
    
}
