//
//  MainRootViewController.swift
//  EcoDatumIOSApp
//
//  Created by Kenneth Wingerden on 3/26/19.
//  Copyright © 2019 Kenneth Wingerden. All rights reserved.
//

import CoreData
import EcoDatumCoreData
import Foundation
import UIKit

class NotebookRootViewController: UITableViewController, CoreDataContextHolder {

    var context: NSManagedObjectContext! {
        didSet {
            log.debug("did set")
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        log.debug("viewDidLoad()")
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add,
                                        target: self,
                                        action: #selector(handleAddButtonPressed))
        
        setToolbarItems([addButton], animated: true)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        log.debug("numberOfRowsInSection: \(section)")
        do {
            return try NotebookEntity.count(context)
        } catch let error as NSError {
            log.error("Failed to get Notebook count: \(error)")
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        log.debug("didSelectRowAt: \(indexPath)")
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        log.debug("cellForRowAt: \(indexPath)")
        var names: [String] = []
        do {
            names = try NotebookEntity.names(context)
        } catch let error as NSError {
            log.error("Failed to get Notebook names: \(error)")
            return UITableViewCell()
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        cell.textLabel?.text = names[indexPath.row]
        return cell
    }
    
    @objc private func handleAddButtonPressed() {
        log.debug("handleAddButtonPressed")
    }
}
