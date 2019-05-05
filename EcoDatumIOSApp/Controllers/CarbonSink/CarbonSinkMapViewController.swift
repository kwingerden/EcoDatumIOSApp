//
//  CarbonSinkMapViewController.swift
//  EcoDatumIOSApp
//
//  Created by Kenneth Wingerden on 5/1/19.
//  Copyright © 2019 Kenneth Wingerden. All rights reserved.
//

import CoreData
import EcoDatumCoreData
import EcoDatumService
import Foundation
import UIKit

class CarbonSinkMapViewController: UIViewController, CoreDataContextHolder, SiteEntityHolder  {
    
    var context: NSManagedObjectContext!
    
    var site: SiteEntity!
    
    @IBOutlet weak var doneButtonItem: UIBarButtonItem!
    
    @IBOutlet weak var imageWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "\(site.name!) - Map"
        let imageName = site.name!.split(separator: " ")[1]
        imageView.image = UIImage(named: "CarbonSinkMaps/\(imageName)")
    }
    
    @IBAction func buttonPressed(_ sender: UIBarButtonItem) {
        if sender == doneButtonItem {
            dismiss(animated: true, completion: nil)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        var heightMultiplier: CGFloat = 0.0
        if  UIDevice.current.orientation == UIDeviceOrientation.portrait ||
            UIDevice.current.orientation == UIDeviceOrientation.portraitUpsideDown {
            heightMultiplier = 0.85
        } else {
            heightMultiplier = 0.75
        }
        imageWidthConstraint.constant = min(view.frame.width - 20, view.frame.height * heightMultiplier)
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 15
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = EDRichBlack.cgColor
    }
}
