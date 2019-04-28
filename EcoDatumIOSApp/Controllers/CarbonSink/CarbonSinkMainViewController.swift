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
    
    private var models: [CarbonSinkTableCellModel] = []
    
    private let NOTEBOOK_NAME = "ERHS Carbon Sink - 2019"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let imageViewNib = UINib.init(nibName: "CarbonSinkImageView", bundle: nil)
        let dataViewNib = UINib.init(nibName: "CarbonSinkDataView", bundle: nil)
        
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
                
                let treeImageView = imageViewNib.instantiate(
                    withOwner: nil, options: nil)[0] as! CarbonSinkImageView
                treeImageView.imageView.image = UIImage(named: "tree_\(index)_tree")!
                
                let mapImageView = imageViewNib.instantiate(
                    withOwner: nil, options: nil)[0] as! CarbonSinkImageView
                mapImageView.imageView.image = UIImage(named: "tree_\(index)_map")!
                
                let dataView = dataViewNib.instantiate(
                    withOwner: nil, options: nil)[0] as! CarbonSinkDataView
                
                let model = CarbonSinkTableCellModel(
                    index: index,
                    siteEntity: siteEntity!,
                    treeImageView: treeImageView,
                    mapImageView: mapImageView,
                    dataView: dataView,
                    selectedView: .Tree)
                models.append(model)
            } catch let error as NSError {
                log.error("Failed to add site \(index): \(error)")
            }
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if UIDevice.current.orientation.isLandscape {
            return view.frame.height - 100.0
        } else {
            return view.frame.height * 0.7
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return models[section].siteEntity.name!
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return models.map({$0.siteEntity.name!})
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return models.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")! as! CarbonSinkTableCellView
        cell.model = models[indexPath.section]
        return cell
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if UIDevice.current.orientation.isLandscape {
            print("Landscape")
        } else {
            print("Portrait")
        }
    }
    
}
