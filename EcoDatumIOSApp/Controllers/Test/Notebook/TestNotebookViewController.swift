//
//  TestNotebookViewController.swift
//  EcoDatumIOSApp
//
//  Created by Kenneth Wingerden on 3/31/19.
//  Copyright © 2019 Kenneth Wingerden. All rights reserved.
//

import CoreData
import EcoDatumCoreData
import Foundation
import UIKit

class TestNotebookViewController: UITableViewController, CoreDataContextHolder {
    
    var context: NSManagedObjectContext!
    
    private var testNotebookHeaderView: UINib!
    
    private var testNotebookFooterView: UINib!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        testNotebookHeaderView = UINib.init(nibName: "TestNotebookHeaderView", bundle: nil)
        testNotebookFooterView = UINib.init(nibName: "TestNotebookFooterView", bundle: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Hide separators for empty cells
        tableView.tableFooterView = UIView(frame: .zero)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        log.debug("numberOfSections")
        do {
            return try NotebookEntity.count(context)
        } catch let error as NSError {
            log.error("Failed to get Notebook count: \(error)")
        }
        return 0
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        log.debug("sectionIndexTitles:")
        do {
            return try NotebookEntity.names(context)
        } catch let error as NSError {
            log.error("Failed to get Notebook names: \(error)")
        }
        return []
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = testNotebookHeaderView.instantiate(withOwner: nil, options: nil)
        return headerView[0] as? UIView ?? nil
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 100
    }

    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = testNotebookFooterView.instantiate(withOwner: nil, options: nil)
        return footerView[0] as? UIView ?? nil 
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 100
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        log.debug("numberOfRowsInSection: \(section)")
        do {
            let notebookNames = try NotebookEntity.names(context)
            let notebookName = notebookNames[section]
            return try SiteEntity.count(context, in: notebookName)
        } catch let error as NSError {
            log.error("Failed to get Site count for Notebook: \(error)")
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        log.debug("didSelectRowAt: \(indexPath)")
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        log.debug("cellForRowAt: \(indexPath)")
        do {
            let notebookNames = try NotebookEntity.names(context)
            let notebookName = notebookNames[indexPath.section]
            let siteNames = try SiteEntity.names(context, in: notebookName)
            let siteName = siteNames[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
            cell.textLabel?.text = siteName
            return cell
        } catch let error as NSError {
            log.error("Failed to get Site count for Notebook: \(error)")
        }
        return UITableViewCell()
    }
    
}
