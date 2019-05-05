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

class CarbonSinkMainViewController: UICollectionViewController,
UICollectionViewDelegateFlowLayout, CoreDataContextHolder {
    
    var context: NSManagedObjectContext!
    
    @IBOutlet weak var uploadButton: UIBarButtonItem!
    
    @IBOutlet weak var scanCodeButton: UIBarButtonItem!
    
    @IBOutlet weak var deleteButton: UIBarButtonItem!
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    private var notebook: NotebookEntity!
    
    private var sites: [SiteEntity] = []
    
    private var selectedSite: SiteEntity!
    
    private let NOTEBOOK_NAME = "ERHS Carbon Sink - 2019"
    
    private let numberFormatter: NumberFormatter = {
        let nf = NumberFormatter()
        nf.generatesDecimalNumbers = true
        nf.maximumIntegerDigits = 6
        nf.maximumFractionDigits = 6
        return nf
    }()
    
    private let carbonFormatter: NumberFormatter = {
        let nf = NumberFormatter()
        nf.generatesDecimalNumbers = true
        nf.maximumIntegerDigits = 6
        nf.maximumFractionDigits = 2
        return nf
    }()
    
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
        
        for index in 1...12 {
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        collectionView.reloadData()
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
        } else if sender == deleteButton {
            deleteData()
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
        cell.thumbnailImageView.image = UIImage(named: "CarbonSinkTrees/\(treeNumber)/1")
        cell.titleLabel.text = "Tree \(treeNumber)"
        
        let site = sites[indexPath.row]
        do {
            let ecoData = try site.ecoData()
            if ecoData.count == 1 {
                let ecoDatum = ecoData[0]
                if let primaryType = ecoDatum.primaryType,
                    primaryType == PrimaryType.Biotic.rawValue,
                    let secondaryType = ecoDatum.secondaryType,
                    secondaryType == SecondaryType.OrganicCarbon.rawValue,
                    let dataType = ecoDatum.dataType,
                    dataType == DataType.Carbon.rawValue,
                    let dataUnit = ecoDatum.dataUnit,
                    dataUnit == DataUnit.KilogramsOfCarbon.rawValue,
                    let data = ecoDatum.dataValue {
                    let dataValue = try JSONDecoder().decode(CarbonSinkDataValue.self, from: data)
                    cell.heightLabel.text = numberFormatter.string(from: NSDecimalNumber(decimal: dataValue.heightInMeters))
                    cell.circumferenceLabel.text = numberFormatter.string(from: NSDecimalNumber(decimal: dataValue.circumferenceInMeters))
                    cell.carbonLabel.text = carbonFormatter.string(from: NSDecimalNumber(decimal: dataValue.carbonInKilograms))
                    cell.layer.borderColor = #colorLiteral(red: 0, green: 0.9768045545, blue: 0, alpha: 1)
                    cell.layer.borderWidth = 4
                }
            } else {
                cell.heightLabel.text = "____"
                cell.circumferenceLabel.text = "____"
                cell.carbonLabel.text = "____"
            }
        } catch let error as NSError {
            log.error("Failed to get EcoData for site \(site.name!): \(error)")
        }
        
        if treeNumber == 7 || treeNumber == 9 {
            cell.layer.borderColor = #colorLiteral(red: 0, green: 0.9768045545, blue: 0, alpha: 1)
            cell.layer.borderWidth = 4
            cell.heightLabel.text = "n/a"
            cell.circumferenceLabel.text = "n/a"
            cell.carbonLabel.text = "n/a"
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedSite = sites[indexPath.row]
        let treeNumber = selectedSite.name!.split(separator: " ")[1]
        if treeNumber == "7" || treeNumber == "9" {
            return
        }
        performSegue(withIdentifier: "detailView", sender: nil)
    }
    
    private func deleteData() {
        let okAction = UIAlertAction(title: "OK", style: .destructive) { _ in
            DispatchQueue.main.async {
                self.displaySecondDeleteDialog()
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let alertController = UIAlertController(
            title: "Delete All Data?",
            message: "Are you sure you want to delete all data?",
            preferredStyle: .alert)
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    private func displaySecondDeleteDialog() {
        let deleteAllAction = UIAlertAction(title: "Delete All Data", style: .destructive) { _ in
            do {
                for site in self.sites {
                    try site.deleteAllEcoData()
                }
                try self.context.save()
            } catch let error as NSError {
                log.error("Failed to all site data: \(error)")
            }
            self.collectionView.reloadData()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default)
        let alertController = UIAlertController(
            title: "Confirmation",
            message: "Please confirm.",
            preferredStyle: .actionSheet)
        alertController.addAction(deleteAllAction)
        alertController.addAction(cancelAction)
        alertController.popoverPresentationController?.barButtonItem = deleteButton
        present(alertController, animated: true, completion: nil)
    }
    
}
