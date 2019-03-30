//
//  SiteDetailViewController.swift
//  EcoDatumIOSApp
//
//  Created by Kenneth Wingerden on 3/29/19.
//  Copyright © 2019 Kenneth Wingerden. All rights reserved.
//

import CoreData
import EcoDatumCoreData
import EcoDatumService
import Foundation
import UIKit

class SiteDetailViewController: UITableViewController, CoreDataContextHolder {
    
    var context: NSManagedObjectContext! {
        didSet {
            log.debug("did set")
        }
    }
    
    private var notebookName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        log.debug("viewDidLoad()")
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add,
                                        target: self,
                                        action: #selector(handleAddButtonPressed))
        
        setToolbarItems([addButton], animated: true)
        
        // Hide separators for empty cells
        tableView.tableFooterView = UIView(frame: .zero)
        
        let nib = UINib.init(nibName: "SiteMasterTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "SiteMasterTableViewCell")
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
            
        case is SitePhotoViewController:
            guard let sitePhotoViewController = segue.destination as? SitePhotoViewController else {
                log.error("Unexpected destination \(segue.destination)")
                return
            }
            guard let cell = sender as? SiteMasterTableViewCell else {
                log.error("Unexpected sender \(String(describing: sender))")
                return
            }
            guard let siteName = cell.siteNameLabel.text else {
                log.error("Failed to get Site name from cell label")
                return
            }
            guard let notebookName = notebookName else {
                log.error("Notebook name should not be nil")
                return
            }
            sitePhotoViewController.setContext(context,
                                               with: siteName,
                                               in: notebookName,
                                               target: cell.siteImageView)
        
        default:
            log.error("Unexpected segue destination \(segue.destination)")
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return SiteMasterTableViewCell.CELL_HEIGHT
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        log.debug("numberOfRowsInSection: \(section)")
        
        guard let notebookName = notebookName else {
            return 0
        }
        
        do {
            return try SiteEntity.count(context, in: notebookName)
        } catch let error as NSError {
            log.error("Failed to get Site count: \(error)")
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        log.debug("cellForRowAt: \(indexPath)")
        
        guard let notebookName = notebookName else {
            log.error("Failed to determine Notebook name")
            return UITableViewCell()
        }
        
        var siteNames: [String] = []
        do {
            siteNames = try SiteEntity.names(context, in: notebookName)
        } catch let error as NSError {
            log.error("Failed to get Site names: \(error)")
            return UITableViewCell()
        }
        
        if indexPath.row < siteNames.count {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "SiteMasterTableViewCell") as? SiteMasterTableViewCell {
                let siteName = siteNames[indexPath.row]
                do {
                    try cell.setContext(context,
                                        with: siteName,
                                        in: notebookName,
                                        performSegue: self.performSegue)
                    return cell
                } catch let error as NSError {
                    log.error("Failed to set SiteMasterTableViewCell context for Site \(siteName): \(error)")
                    return UITableViewCell()
                }
            } else {
                log.error("Failed to obtain reference to SiteMasterTableViewCell")
                return UITableViewCell()
            }
        } else {
            log.error("Index path row is less than the number of Sites")
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
        
        self.notebookName = name
        
        tableView.reloadData()
    }
    
    @objc private func handleAddButtonPressed() {
        log.debug("handleAddButtonPressed")
        
        guard let notebookName = notebookName else {
            log.error("Failed to get Notebook name")
            return
        }
        
        let newSiteController = UIAlertController(
            title: "New Site",
            message: "Enter new Site name:",
            preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "Save", style: .default) { _ in
            let siteName = newSiteController.textFields![0].text!
            do {
                let site = try SiteEntity.new(self.context,
                                              with: siteName,
                                              in: notebookName)
                try site.save()
                self.tableView.reloadData()
            } catch SiteEntity.EntityError.NotebookDoesNotExist(let name) {
                log.error("Notebook with name: \(name) does not exist")
            } catch SiteEntity.EntityError.NameAlreadyExists(let name) {
                let siteExistsController = UIAlertController(
                    title: "Conflict",
                    message: "Site with the name \(name) already exists.",
                    preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default) { (_) in }
                siteExistsController.addAction(okAction)
                self.present(siteExistsController, animated: true, completion: nil)
            } catch let error as NSError {
                log.error("Failed to save Site with name: \(siteName), \(error)")
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
        newSiteController.addTextField { (textField) in
            textField.placeholder = "Enter name"
        }
        
        newSiteController.addAction(confirmAction)
        newSiteController.addAction(cancelAction)
        
        present(newSiteController, animated: true, completion: nil)
    }
    
}
