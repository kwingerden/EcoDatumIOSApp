//
//  CarbonSinkKeyboardView.swift
//  EcoDatumIOSApp
//
//  Created by Kenneth Wingerden on 5/7/19.
//  Copyright © 2019 Kenneth Wingerden. All rights reserved.
//

import Foundation
import UIKit

class CarbonSinkKeyboardView: UIView {

    @IBOutlet weak var oneButton: UIButton!
    
    @IBOutlet weak var twoButton: UIButton!
    
    @IBOutlet weak var threeButton: UIButton!
    
    @IBOutlet weak var fourButton: UIButton!
    
    @IBOutlet weak var fiveButton: UIButton!
    
    @IBOutlet weak var sixButton: UIButton!
    
    @IBOutlet weak var sevenButton: UIButton!
    
    @IBOutlet weak var eightButton: UIButton!
    
    @IBOutlet weak var nineButton: UIButton!
    
    @IBOutlet weak var decimalButton: UIButton!
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        /*
        switch sender {
        case oneButton:
        case twoButton:
            case threeButton:
            case fourButton:
            case fiveButton:
            case sixButton:
            case sevenButton:
            case eightButton:
            case nineButton:
            case decimalButton:
        default:
            log.error("Unexpected button \(sender)")
        }
 */
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        styleButton(oneButton)
        styleButton(twoButton)
        styleButton(threeButton)
        styleButton(fourButton)
        styleButton(fiveButton)
        styleButton(sixButton)
        styleButton(sevenButton)
        styleButton(eightButton)
        styleButton(nineButton)
        styleButton(decimalButton)
    }
    
    private func styleButton(_ button: UIButton) {
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 15
        button.layer.borderWidth = 1
        button.layer.borderColor = EDRichBlack.cgColor
    }
}
