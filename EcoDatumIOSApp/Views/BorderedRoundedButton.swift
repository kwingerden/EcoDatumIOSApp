//
//  RoundedButton.swift
//  EcoDatumIOSApp
//
//  Created by Kenneth Wingerden on 3/12/19.
//  Copyright © 2019 Kenneth Wingerden. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable class BorderedRoundedButton: UIControl {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var button: UIButton!
    
    /*
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
 */
    
    override func awakeFromNib() {
        super.awakeFromNib()
        print("awke")
        initNib()
    }
    
    func initNib() {
        let bundle = Bundle(for: BorderedRoundedButton.self)
        bundle.loadNibNamed("BorderedRoundedButton", owner: self, options: nil)
        addSubview(containerView)
        containerView.frame = bounds
        containerView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
    
    @IBAction func touchUpInside(_ sender: UIButton) {
        print("hello")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        containerView.layer.cornerRadius = frame.size.height / 2
        containerView.backgroundColor = EDAsparagus
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = EDRichBlack.cgColor
        button.showsTouchWhenHighlighted = true
    }
   
    override func prepareForInterfaceBuilder() {
        print("prepareForInterfaceBuilder")
    }
    
}
