//
//  TreeTableCellView.swift
//  EcoDatumIOSApp
//
//  Created by Kenneth Wingerden on 4/25/19.
//  Copyright © 2019 Kenneth Wingerden. All rights reserved.
//

import Foundation
import UIKit

class CarbonSinkCellView: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var thumbnailImageView: UIImageView!
 
    @IBOutlet weak var heightLabel: UILabel!
    
    @IBOutlet weak var circumferenceLabel: UILabel!
    
    @IBOutlet weak var carbonLabel: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        thumbnailImageView.layer.cornerRadius = 15
    }
}
