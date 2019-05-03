//
//  CarbonSinkImageView.swift
//  EcoDatumIOSApp
//
//  Created by Kenneth Wingerden on 4/26/19.
//  Copyright © 2019 Kenneth Wingerden. All rights reserved.
//

import Foundation
import UIKit

class CarbonSinkImageView: UIView {
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var imageWidthConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        frame = superview!.frame
        imageWidthConstraint.constant = min(frame.width - 20, frame.height * 0.7)
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 15
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = EDRichBlack.cgColor
    }
    
}
