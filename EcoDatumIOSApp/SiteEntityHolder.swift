//
//  SiteEntityHolder.swift
//  EcoDatumIOSApp
//
//  Created by Kenneth Wingerden on 5/1/19.
//  Copyright © 2019 Kenneth Wingerden. All rights reserved.
//

import EcoDatumCoreData
import EcoDatumModel
import CoreData
import Foundation

protocol SiteEntityHolder {
    
    var site: SiteEntity! { set get }
    
}
