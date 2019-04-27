//
//  TreeTableCellView.swift
//  EcoDatumIOSApp
//
//  Created by Kenneth Wingerden on 4/25/19.
//  Copyright © 2019 Kenneth Wingerden. All rights reserved.
//

import Foundation
import UIKit

class CarbonSinkTableCellView: UITableViewCell {
    
    var index: Int!
    
    var controller: CarbonSinkMainViewController!
    
    @IBOutlet weak var treeImage: UIImageView!
    
    @IBOutlet weak var treeSegmentedControl: UISegmentedControl!

    @IBAction func treePressed(_ sender: UISegmentedControl) {
        controller.updateCell(self)
    }
    
}
