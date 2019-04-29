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
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    private var sites: [SiteEntity] = []
    
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
                var site = try notebook?.findSite(by: "Tree \(index)")
                if site == nil {
                    site = try SiteEntity.new(
                        context,
                        name: "Tree \(index)",
                        in: notebook)
                    try site!.save()
                }
                sites.append(site!)
            } catch let error as NSError {
                log.error("Failed to add site \(index): \(error)")
            }
        }
    }

    @IBAction func buttonPressed(_ sender: UIBarButtonItem) {
        if sender == doneButton {
            dismiss(animated: true, completion: nil)
        } else {
            log.error("Unknown button \(sender)")
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sites.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")! as! CarbonSinkTableCellView
        cell.thumbnailImageView.image = UIImage(named: "tree_\(indexPath.row + 1)_tree")
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
