//
//  CarbonSinkDataView.swift
//  EcoDatumIOSApp
//
//  Created by Kenneth Wingerden on 4/26/19.
//  Copyright © 2019 Kenneth Wingerden. All rights reserved.
//

import Foundation
import UIKit

class CarbonSinkDataView: UIView {
    
    @IBOutlet weak var tableView: UITableView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        frame = superview!.bounds
    }
    
}
