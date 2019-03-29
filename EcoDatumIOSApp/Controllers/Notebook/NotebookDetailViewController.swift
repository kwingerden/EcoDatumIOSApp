//
//  MainViewController.swift
//  EcoDatumIOSApp
//
//  Created by Kenneth Wingerden on 3/26/19.
//  Copyright © 2019 Kenneth Wingerden. All rights reserved.
//

import CoreData
import EcoDatumCoreData
import EcoDatumService
import Foundation
import UIKit

class NotebookDetailViewController: UITableViewController, CoreDataContextHolder {
        
    var context: NSManagedObjectContext! {
        didSet {
            log.debug("did set")
        }
    }
    
    private var name: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        log.debug("viewDidLoad()")
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add,
                                        target: self,
                                        action: #selector(handleAddButtonPressed))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                            target: nil,
                                            action: nil)
        let trashButton = UIBarButtonItem(barButtonSystemItem: .trash,
                                          target: self,
                                          action: #selector(handleTrashButtonPressed))
        
        setToolbarItems([addButton, flexibleSpace, trashButton], animated: true)
        
        // Hide separators for empty cells
        tableView.tableFooterView = UIView(frame: .zero)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(notebookSelected(_:)),
                                               name: .notebookSelected,
                                               object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
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
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        log.debug("cellForRowAt: \(indexPath)")
        
        guard let name = name else {
            return UITableViewCell()
        }
        
        var names: [String] = []
        do {
            names = try SiteEntity.names(context, in: name)
        } catch let error as NSError {
            log.error("Failed to get Site names: \(error)")
            return UITableViewCell()
        }
        
        if indexPath.row < names.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
            cell.textLabel?.text = names[indexPath.row]
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    @objc private func notebookSelected(_ notification: Notification) {
        guard notification.name == .notebookSelected else {
            log.error("Unexpected Notebook notification: \(notification)")
            return
        }
        
        guard let data = notification.userInfo as? [String: String],
            let name = data["name"] else {
                log.error("Failed to get Notebook name from notification: \(notification)")
                return
        }
        
        self.name = name
        
        tableView.reloadData()
    }
    
    @objc private func handleAddButtonPressed() {
        log.debug("handleAddButtonPressed")
        
        /*
         let newNotebookController = UIAlertController(
         title: "New Notebook",
         message: "Enter new Notebook name:",
         preferredStyle: .alert)
         
         let confirmAction = UIAlertAction(title: "Save", style: .default) { _ in
         let name = newNotebookController.textFields![0].text!
         if let exists = try? NotebookEntity.exists(self.context, with: name), exists {
         let notebookExistsController = UIAlertController(
         title: "Conflict",
         message: "Notebook with the name \(name) already exists.",
         preferredStyle: .alert)
         let okAction = UIAlertAction(title: "OK", style: .default) { (_) in }
         notebookExistsController.addAction(okAction)
         self.present(notebookExistsController, animated: true, completion: nil)
         } else {
         let notebook = NotebookEntity.new(self.context, name: name)
         do {
         try notebook.save()
         } catch let error as NSError {
         log.error("Failed to save new Notebook \(name): \(error)")
         }
         self.tableView.reloadData()
         }
         }
         
         let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
         
         newNotebookController.addTextField { (textField) in
         textField.placeholder = "Enter name"
         }
         
         newNotebookController.addAction(confirmAction)
         newNotebookController.addAction(cancelAction)
         
         present(newNotebookController, animated: true, completion: nil)
         */
    }
    
    @objc private func handleTrashButtonPressed() {
        log.debug("handleTrashButtonPressed")
        
        /*
         guard let indexPath = tableView.indexPathForSelectedRow,
         let cell = tableView.cellForRow(at: indexPath),
         let name = cell.textLabel?.text else {
         return
         }
         
         guard let optional = try? NotebookEntity.find(context, with: name),
         let notebook = optional else {
         log.error("Failed to find Notebook with name \(name)")
         return
         }
         
         let notebookDeleteController = UIAlertController(
         title: "Delete",
         message: "Are you sure you want to delete Notebook \(name).",
         preferredStyle: .alert)
         let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
         let yesAction = UIAlertAction(title: "Yes", style: .default) { (_) in
         notebook.delete()
         do {
         try notebook.save()
         } catch let error as NSError {
         log.error("Failed to delete new Notebook \(name): \(error)")
         }
         self.tableView.reloadData()
         }
         notebookDeleteController.addAction(cancelAction)
         notebookDeleteController.addAction(yesAction)
         present(notebookDeleteController, animated: true, completion: nil)
         */
    }
    
}
