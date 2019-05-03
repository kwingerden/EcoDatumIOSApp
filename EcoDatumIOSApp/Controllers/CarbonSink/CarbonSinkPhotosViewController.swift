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
        
        let iv1 = imageViewNib.instantiate(withOwner: nil, options: nil)[0] as! CarbonSinkImageView
        iv1.dateLabel.text = "2018-06-03"
        iv1.imageView.image = UIImage(named: "tree_1_tree")
        let vc1 = UIViewController()
        vc1.view.addSubview(iv1)
        
        let iv2 = imageViewNib.instantiate(withOwner: nil, options: nil)[0] as! CarbonSinkImageView
        iv2.dateLabel.text = "2019-05-02"
        iv2.imageView.image = UIImage(named: "tree_2_tree")
        let vc2 = UIViewController()
        vc2.view.addSubview(iv2)
        
        let iv3 = imageViewNib.instantiate(withOwner: nil, options: nil)[0] as! CarbonSinkImageView
        iv3.dateLabel.text = "2019-05-02"
        iv3.imageView.image = UIImage(named: "tree_3_tree")
        let vc3 = UIViewController()
        vc3.view.addSubview(iv3)
        
        setViewControllers(
            [
                vc1
            ],
            direction: .forward,
            animated: true,
            completion: nil)
        _viewControllers = [vc1, vc2, vc3]
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
