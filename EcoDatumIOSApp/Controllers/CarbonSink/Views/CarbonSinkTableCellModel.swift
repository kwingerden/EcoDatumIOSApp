//
//  CarbonSinkTreeData.swift
//  EcoDatumIOSApp
//
//  Created by Kenneth Wingerden on 4/26/19.
//  Copyright © 2019 Kenneth Wingerden. All rights reserved.
//

import EcoDatumCoreData
import Foundation
import UIKit

struct CarbonSinkTableCellModel {
    
    enum View: Int {
        case Tree = 0
        case Map = 1
        case Data = 2
    }
    
    let index: Int
    let siteEntity: SiteEntity
    let treeImageView: UIView
    let mapImageView: UIView
    let dataView: UIView
    var selectedView: View
    
}
