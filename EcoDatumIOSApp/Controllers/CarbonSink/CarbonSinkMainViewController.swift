//
//  CarbonSinkMainViewController.swift
//  EcoDatumIOSApp
//
//  Created by Kenneth Wingerden on 4/25/19.
//  Copyright © 2019 Kenneth Wingerden. All rights reserved.
//

import CoreData
import CoreLocation
import EcoDatumCoreData
import EcoDatumModel
import EcoDatumService
import Foundation
import UIKit

class CarbonSinkMainViewController: UITableViewController, CoreDataContextHolder {
    
    var context: NSManagedObjectContext!
    
    private struct Site {
        let entity: SiteEntity
        let treeImage: UIImage
        let treeLocation: UIImage
        var treeImageIndex: Int
    }
    
    private var sites: [Site] = []
    
    private let NOTEBOOK_NAME = "ERHS Carbon Sink - 2019"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var notebook: NotebookEntity?
        do {
            notebook = try NotebookEntity.new(context, name: NOTEBOOK_NAME)
            try notebook?.save()
        } catch NotebookEntity.EntityError.NameAlreadyExists(let name) {
            log.debug("Notebook \(name) already exists")
        } catch let error as NSError {
            log.error("Failed to create \(NOTEBOOK_NAME) Notebook: \(error)")
            return
        }
        
        do {
            notebook = try NotebookEntity.find(context, with: NOTEBOOK_NAME)
        } catch let error as NSError {
            log.error("Failed to find \(NOTEBOOK_NAME) Notebook: \(error)")
            return
        }
        
        for index in 1...10 {
            do {
                var siteEntity = try notebook?.findSite(by: "Tree \(index)")
                if siteEntity == nil {
                    siteEntity = try SiteEntity.new(
                        context,
                        name: "Tree \(index)",
                        in: notebook)
                    try siteEntity!.save()
                }
                
                let site = Site(
                    entity: siteEntity!,
                    treeImage: UIImage(named: "tree_\(index)")!,
                    treeLocation: UIImage(named: "tree_\(index)_loc")!,
                    treeImageIndex: 0)
                sites.append(site)
            } catch let error as NSError {
                log.error("Failed to add site \(index): \(error)")
            }
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if UIDevice.current.orientation.isLandscape {
            return CGFloat(842)
        } else {
            return CGFloat(542)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sites[section].entity.name!
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return sites.map({$0.entity.name!})
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sites.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")! as! CarbonSinkTableCellView
        let site = sites[indexPath.section]
        cell.index = indexPath.section
        cell.controller = self
        if site.treeImageIndex == 0 {
            cell.treeImage.image = site.treeImage
        } else {
            cell.treeImage.image = site.treeLocation
        }
        cell.treeSegmentedControl.selectedSegmentIndex = site.treeImageIndex
        
        return cell
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if UIDevice.current.orientation.isLandscape {
            print("Landscape")
        } else {
            print("Portrait")
        }
    }
    
    func updateCell(_ cell: CarbonSinkTableCellView) {
        sites[cell.index].treeImageIndex = cell.treeSegmentedControl.selectedSegmentIndex
        tableView.reloadSections(IndexSet(arrayLiteral: cell.index), with: .none)
    }
    
}
