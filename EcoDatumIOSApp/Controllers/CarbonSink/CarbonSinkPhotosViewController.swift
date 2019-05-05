//
//  CarbonSinkPhotoViewController.swift
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

class CarbonSinkPhotosViewController: UIPageViewController,
CoreDataContextHolder, SiteEntityHolder, UIPageViewControllerDelegate,
UIPageViewControllerDataSource {
    
    var context: NSManagedObjectContext!
    
    var site: SiteEntity!
    
    @IBOutlet weak var doneButtonItem: UIBarButtonItem!
    
    private var _viewControllers: [UIViewController] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        delegate = self
        dataSource = self
        
        navigationItem.title = "\(site.name!) - Photos"
        
        let appearance = UIPageControl.appearance(whenContainedInInstancesOf: [UIPageViewController.self])
        appearance.pageIndicatorTintColor = EDRichBlack
        appearance.currentPageIndicatorTintColor = EDPlatinum
        appearance.backgroundColor = EDCerulean
        
        let imageViewNib = UINib.init(nibName: "CarbonSinkImageView", bundle: nil)
        
        let treeNumber = site.name!.split(separator: " ")[1]
        
        let iv1 = imageViewNib.instantiate(withOwner: nil, options: nil)[0] as! CarbonSinkImageView
        iv1.dateLabel.text = "2018-05-30"
        iv1.imageView.image = UIImage(named: "CarbonSinkTrees/\(treeNumber)/1")
        let vc1 = UIViewController()
        vc1.view.addSubview(iv1)
        
        _viewControllers = [vc1]
        
        if treeNumber == "1" || treeNumber == "2" || treeNumber == "3" || treeNumber == "4" ||
            treeNumber == "5" || treeNumber == "6" || treeNumber == "8" || treeNumber == "10" {
            let iv2 = imageViewNib.instantiate(withOwner: nil, options: nil)[0] as! CarbonSinkImageView
            iv2.dateLabel.text = "2019-05-04"
            iv2.imageView.image = UIImage(named: "CarbonSinkTrees/\(treeNumber)/2")
            let vc2 = UIViewController()
            vc2.view.addSubview(iv2)
            
            _viewControllers = [vc1, vc2]
        }
        
        setViewControllers(
            [
                _viewControllers[0]
            ],
            direction: .forward,
            animated: true,
            completion: nil)
    }
    @IBAction func buttonPressed(_ sender: UIBarButtonItem) {
        if sender == doneButtonItem {
            dismiss(animated: true, completion: nil)
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let index = _viewControllers.firstIndex(of: viewController)!
        if index == 0 {
            return nil
        } else {
            return _viewControllers[index - 1]
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let index = _viewControllers.firstIndex(of: viewController)!
        if index == _viewControllers.count - 1 {
            return nil
        } else {
            return _viewControllers[index + 1]
        }
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return _viewControllers.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
}
