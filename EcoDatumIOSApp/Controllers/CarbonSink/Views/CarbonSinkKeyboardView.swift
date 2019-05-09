//
//  CarbonSinkKeyboardView.swift
//  EcoDatumIOSApp
//
//  Created by Kenneth Wingerden on 5/7/19.
//  Copyright © 2019 Kenneth Wingerden. All rights reserved.
//

import Foundation
import UIKit

enum CarbonSinkKeyboardKey: String {
    case one = "1"
    case two = "2"
    case three = "3"
    case four = "4"
    case five = "5"
    case six = "6"
    case seven = "7"
    case eight = "8"
    case nine = "9"
    case zero = "0"
    case decimal = "."
    case delete = "Del"
}

protocol CarbonSinkKeyboardDelegate {
    func keyPressed(_ key: CarbonSinkKeyboardKey)
}

class CarbonSinkKeyboardView: UIView {
    
    var delegate: CarbonSinkKeyboardDelegate?
    
    @IBOutlet weak var oneButton: UIButton!
    
    @IBOutlet weak var twoButton: UIButton!
    
    @IBOutlet weak var threeButton: UIButton!
    
    @IBOutlet weak var fourButton: UIButton!
    
    @IBOutlet weak var fiveButton: UIButton!
    
    @IBOutlet weak var sixButton: UIButton!
    
    @IBOutlet weak var sevenButton: UIButton!
    
    @IBOutlet weak var eightButton: UIButton!
    
    @IBOutlet weak var nineButton: UIButton!
    
    @IBOutlet weak var zeroButton: UIButton!
    
    @IBOutlet weak var decimalButton: UIButton!
    
    @IBOutlet weak var deleteButton: UIButton!
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        if let title = sender.titleLabel?.text,
            let key = CarbonSinkKeyboardKey(rawValue: title),
            let delegate = delegate {
            delegate.keyPressed(key)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        [
            oneButton,
            twoButton,
            threeButton,
            fourButton,
            fiveButton,
            sixButton,
            sevenButton,
            eightButton,
            nineButton,
            zeroButton,
            deleteButton,
            decimalButton
            ].forEach {
                styleButton($0)
        }
    }
    
    private func styleButton(_ button: UIButton) {
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 15
        button.layer.borderWidth = 1
        button.layer.borderColor = EDRichBlack.cgColor
    }
}
