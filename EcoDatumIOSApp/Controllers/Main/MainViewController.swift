//
//  MainViewController.swift
//  EcoDatumIOSApp
//
//  Created by Kenneth Wingerden on 4/28/19.
//  Copyright © 2019 Kenneth Wingerden. All rights reserved.
//

import CoreData
import Foundation
import UIKit

class MainViewController: UIViewController, CoreDataContextHolder {
    
    var context: NSManagedObjectContext!
    
    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet weak var carbonSinkERHSButton: UIButton!
    
    @IBOutlet weak var amazonButton: UIButton!
    
    @IBOutlet weak var stackViewWidthConstraint: NSLayoutConstraint!
    
    private let MIN_STACK_VIEW_WIDTH: CGFloat = 200;
    private let MAX_STACK_VIEW_WIDTH: CGFloat = 500;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        carbonSinkERHSButton.layer.borderWidth = 1
        carbonSinkERHSButton.layer.borderColor = EDRichBlack.cgColor
        carbonSinkERHSButton.layer.cornerRadius = 15
        
        amazonButton.layer.borderWidth = 1
        amazonButton.layer.borderColor = EDRichBlack.cgColor
        amazonButton.layer.cornerRadius = 15
    
        updateLayout()
    }
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        if sender == carbonSinkERHSButton {
            performSegue(withIdentifier: "CarbonSink", sender: nil)
        } else if sender == amazonButton {
            
        } else {
            log.error("Unknown button \(sender)")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? CarbonSinkNavigationController {
            vc.context = context
        } else {
            log.error("Unknown segue \(segue)")
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        updateLayout()
    }
    
    private func updateLayout() {
        var newStackViewWidth: CGFloat = MAX_STACK_VIEW_WIDTH
        if view.frame.width < MAX_STACK_VIEW_WIDTH {
            newStackViewWidth = view.frame.width - 30
            if newStackViewWidth < MIN_STACK_VIEW_WIDTH {
                newStackViewWidth = MIN_STACK_VIEW_WIDTH
            }
        } else if view.frame.width > MAX_STACK_VIEW_WIDTH {
            newStackViewWidth = MAX_STACK_VIEW_WIDTH
        }
        
        stackViewWidthConstraint.constant = newStackViewWidth
    }
}
