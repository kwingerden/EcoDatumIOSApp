//
//  CarbonSinkMainViewController.swift
//  EcoDatumIOSApp
//
//  Created by Kenneth Wingerden on 4/25/19.
//  Copyright © 2019 Kenneth Wingerden. All rights reserved.
//

import CoreData
import CoreLocation
import EcoDatumCommon
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
        
        
        let locations = [
            CLLocation(latitude: 34.883979, longitude: -120.422244), // Tree 1
            CLLocation(latitude: 34.884032, longitude: -120.421759), // Tree 2
            CLLocation(latitude: 34.884147, longitude: -120.421879), // Tree 3
            CLLocation(latitude: 34.884177, longitude: -120.421666), // Tree 4
            CLLocation(latitude: 34.884130, longitude: -120.421577), // Tree 5
            CLLocation(latitude: 34.884085, longitude: -120.421600), // Tree 6
            CLLocation(latitude: 34.884036, longitude: -120.421627), // Tree 7
            CLLocation(latitude: 34.883844, longitude: -120.421487), // Tree 8
            CLLocation(latitude: 34.883953, longitude: -120.421279), // Tree 9
            CLLocation(latitude: 34.883964, longitude: -120.421024), // Tree 10
            CLLocation(latitude: 34.884004, longitude: -120.420957), // Tree 11
            CLLocation(latitude: 34.884088, longitude: -120.420873)  // Tree 12
        ]
        for index in 1...12 {
            do {
                var site = try notebook?.findSite(by: "Tree \(index)")
                if site == nil {
                    site = try SiteEntity.new(
                        context,
                        name: "Tree \(index)",
                        at: locations[index - 1],
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
            doExportNotebook(with: UIDevice.current.name)
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
    
    private func startExportNotebook() {
        let alertController = UIAlertController(
            title: "Save File",
            message: "Enter the name of the file or leave blank. If left blank, then the default file name is 'CarbonSink'.",
            preferredStyle: .alert)
        alertController.addTextField {
            $0.placeholder = "Carbon Sink"
        }
        let continueAction = UIAlertAction(title: "Continue", style: .default) { _ in
            guard let textField = alertController.textFields?[0],
                  let text = textField.text else {
                return
            }
            if text.isEmpty {
                self.doExportNotebook(with: "Carbon Sink")
            } else {
                self.doExportNotebook(with: text)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(continueAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    private func doExportNotebook(with name: String) {
        guard let nm = try? notebook.model(),
            let json = try? toJSON(nm) else {
                log.error("Failed to export notebook")
                return
        }
        
        let path = FileManager.default.temporaryDirectory.appendingPathComponent("\(name).ednb")
        do {
            try json.data(using: .utf8)?.write(to: path)
        } catch let error as NSError {
            log.error("Failed to export Notebook to path: \(error) \(path.absoluteString)")
        }
        
        let activity = UIActivityViewController(
            activityItems: [path],
            applicationActivities: nil
        )
        activity.popoverPresentationController?.barButtonItem = uploadButton
        present(activity, animated: true, completion: nil)
    }
    
}
