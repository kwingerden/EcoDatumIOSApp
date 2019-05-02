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
import EcoDatumService
import Foundation
import UIKit

class CarbonSinkMainViewController: UICollectionViewController,
UICollectionViewDelegateFlowLayout, CoreDataContextHolder {
    
    var context: NSManagedObjectContext!
    
    @IBOutlet weak var uploadButton: UIBarButtonItem!
    
    @IBOutlet weak var scanCodeButton: UIBarButtonItem!
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    private var notebook: NotebookEntity!
    
    private var sites: [SiteEntity] = []
    
    private var selectedSite: SiteEntity!
    
    private let NOTEBOOK_NAME = "ERHS Carbon Sink - 2019"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if var vc = segue.destination as? CoreDataContextHolder {
            vc.context = context
        }
        if var vc = segue.destination as? NotebookEntityHolder {
            vc.notebook = notebook
        }
        if var vc = segue.destination as? SiteEntityHolder {
            vc.site = selectedSite
        }
        if var vc = segue.destination as? SiteEntitiesHolder {
            vc.sites = sites
        }
    }
    
    @IBAction func buttonPressed(_ sender: UIBarButtonItem) {
        if sender == uploadButton {

        } else if sender == scanCodeButton {
            performSegue(withIdentifier: "scanCode", sender: nil)
        } else if sender == doneButton {
            dismiss(animated: true, completion: nil)
        } else {
            log.error("Unknown button \(sender)")
        }
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sites.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 250, height: 369)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let treeNumber = indexPath.row + 1
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CarbonSinkCellView
        cell.layer.masksToBounds = true
        cell.layer.cornerRadius = 15
        cell.layer.borderWidth = 1
        cell.layer.borderColor = EDRichBlack.cgColor
        cell.thumbnailImageView.image = UIImage(named: "tree_\(treeNumber)_tree")
        cell.titleLabel.text = "Tree \(treeNumber)"
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedSite = sites[indexPath.row]
        performSegue(withIdentifier: "detailView", sender: nil)
    }
    
}
