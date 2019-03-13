//
//  RoundedButton.swift
//  EcoDatumIOSApp
//
//  Created by Kenneth Wingerden on 3/12/19.
//  Copyright © 2019 Kenneth Wingerden. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable class GreenRoundedButton: UIButton {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.size.height / 2
        backgroundColor = EDAsparagus
        layer.borderWidth = 1
        layer.borderColor = EDRichBlack.cgColor
        showsTouchWhenHighlighted = true
    }
    
}
