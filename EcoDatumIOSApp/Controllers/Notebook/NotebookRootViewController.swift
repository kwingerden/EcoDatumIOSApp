//
//  MainRootViewController.swift
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
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                            target: nil,
                                            action: nil)
        let trashButton = UIBarButtonItem(barButtonSystemItem: .trash,
                                          target: self,
                                          action: #selector(handleTrashButtonPressed))
        
        setToolbarItems([addButton, flexibleSpace, trashButton], animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Hide separators for empty cells
        tableView.tableFooterView = UIView(frame: .zero)
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
        
        var names: [String] = []
        do {
            names = try NotebookEntity.names(context)
        } catch let error as NSError {
            log.error("Failed to get Notebook names: \(error)")
            return
        }
        
        NotificationCenter.default.post(name: .notebookSelected,
                                        object: self,
                                        userInfo: ["name":names[indexPath.row]])
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
        
        let newNotebookController = UIAlertController(
            title: "New Notebook",
            message: "Enter new Notebook name:",
            preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "Save", style: .default) { _ in
            let name = newNotebookController.textFields![0].text!
            do {
                let notebook = try NotebookEntity.new(self.context, name: name)
                try notebook.save()
                self.tableView.reloadData()
            } catch NotebookEntity.EntityError.NameAlreadyExists(let name) {
                let notebookExistsController = UIAlertController(
                    title: "Conflict",
                    message: "Notebook with the name \(name) already exists.",
                    preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default) { (_) in }
                notebookExistsController.addAction(okAction)
                self.present(notebookExistsController, animated: true, completion: nil)
            } catch let error as NSError {
                log.error("Failed to save new Notebook \(name): \(error)")
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
        newNotebookController.addTextField { (textField) in
            textField.placeholder = "Enter name"
        }
        
        newNotebookController.addAction(confirmAction)
        newNotebookController.addAction(cancelAction)
        
        present(newNotebookController, animated: true, completion: nil)
    }
    
    @objc private func handleTrashButtonPressed() {
        log.debug("handleTrashButtonPressed")
        
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
    }
    
}
