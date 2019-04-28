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
    
    var model: CarbonSinkTableCellModel! {
        didSet {
            updateView()
        }
    }
    
    @IBOutlet weak var mainView: UIView!
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBOutlet weak var segmentedControlWidth: NSLayoutConstraint!
    
    @IBAction func segmentedControlPressed() {
        model.selectedView = CarbonSinkTableCellModel.View(
            rawValue: segmentedControl.selectedSegmentIndex)!
        updateView()
    }
    
    override func layoutSubviews() {
        segmentedControlWidth.constant = bounds.width * 0.50
    }
    
    private func updateView() {
        mainView.subviews.forEach({$0.removeFromSuperview()})
        
        var subView: UIView
        switch model.selectedView {
        case .Tree:
            subView = model.treeImageView
        case .Map:
            subView = model.mapImageView
        case .Data:
            subView = model.dataView
        }
        
        mainView.addSubview(subView)
        
        segmentedControl.selectedSegmentIndex = model.selectedView.rawValue
    }
}
