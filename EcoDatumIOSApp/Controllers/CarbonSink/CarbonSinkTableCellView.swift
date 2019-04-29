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
    
    @IBOutlet weak var thumbnailImageView: UIImageView!
 
    override func layoutSubviews() {
        super.layoutSubviews()
        thumbnailImageView.layer.borderWidth = 1
        thumbnailImageView.layer.borderColor = EDRichBlack.cgColor
        thumbnailImageView.layer.cornerRadius = 15
    }
}
