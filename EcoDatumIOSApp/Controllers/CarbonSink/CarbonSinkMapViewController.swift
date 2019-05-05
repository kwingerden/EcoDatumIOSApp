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

class CarbonSinkMapViewController: UIViewController,
CoreDataContextHolder, SiteEntityHolder, UIScrollViewDelegate  {
    
    var context: NSManagedObjectContext!
    
    var site: SiteEntity!
    
    @IBOutlet weak var doneButtonItem: UIBarButtonItem!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "\(site.name!) - Map"
        let imageNumber = site.name!.split(separator: " ")[1]
        imageView.image = UIImage(named: "CarbonSinkMaps/\(imageNumber)")
        imageView.sizeToFit()
        
        scrollView.delegate = self
        scrollView.minimumZoomScale = 0.5
        scrollView.maximumZoomScale = 5.0
        scrollView.zoomScale = 0.5
        scrollView.contentSize = imageView.frame.size
        scrollView.contentOffset = CGPoint(x: 250, y: 0)
    }
    
    @IBAction func buttonPressed(_ sender: UIBarButtonItem) {
        if sender == doneButtonItem {
            dismiss(animated: true, completion: nil)
        }
    }

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
