//
//  CarbonSinkDataViewController.swift
//  EcoDatumIOSApp
//
//  Created by Kenneth Wingerden on 5/1/19.
//  Copyright © 2019 Kenneth Wingerden. All rights reserved.
//

import CoreData
import EcoDatumCoreData
import EcoDatumModel
import EcoDatumService
import Foundation
import UIKit

class CarbonSinkDataViewController: UIViewController,
CoreDataContextHolder, SiteEntityHolder, UITextFieldDelegate  {
    
    var context: NSManagedObjectContext!
    
    var site: SiteEntity!
    
    @IBOutlet weak var doneButtonItem: UIBarButtonItem!
    
    @IBOutlet weak var dataView: UIView!
    
    @IBOutlet weak var heightTextField: UITextField!
    
    @IBOutlet weak var circumferenceTextField: UITextField!
    
    @IBOutlet weak var carbonTextField: UITextField!
    
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
    
    private let allowableCharacterSet = CharacterSet(charactersIn: ".0123456789")
    
    private var ecoDatum: EcoDatumEntity?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "\(site.name!) - Data"
        
        do {
            let ecoData = try site.ecoData()
            if ecoData.count == 1 {
                let ecoDatum = ecoData[0]
                guard let primaryType = ecoDatum.primaryType,
                    primaryType == PrimaryType.Biotic.rawValue,
                    let secondaryType = ecoDatum.secondaryType,
                    secondaryType == SecondaryType.OrganicCarbon.rawValue,
                    let dataType = ecoDatum.dataType,
                    dataType == DataType.Carbon.rawValue,
                    let dataUnit = ecoDatum.dataUnit,
                    dataUnit == DataUnit.KilogramsOfCarbon.rawValue,
                    let data = ecoDatum.dataValue else {
                        log.error("Unexpected EcoDatum \(ecoDatum))")
                        return
                }
                let dataValue = try JSONDecoder().decode(CarbonSinkDataValue.self, from: data)
                heightTextField.text = numberFormatter.string(from: NSDecimalNumber(decimal: dataValue.heightInMeters))
                circumferenceTextField.text = numberFormatter.string(from: NSDecimalNumber(decimal: dataValue.circumferenceInMeters))
                carbonTextField.text = carbonFormatter.string(from: NSDecimalNumber(decimal: dataValue.carbonInKilograms))
                self.ecoDatum = ecoDatum
            }
        } catch let error as NSError {
            log.error("Failed to get EcoDatum for Site \(site.name!): \(error)")
        }
        
        dataView.layer.masksToBounds = true
        dataView.layer.cornerRadius = 15
        dataView.layer.borderWidth = 1
        dataView.layer.borderColor = EDRichBlack.cgColor
        
        heightTextField.delegate = self
        circumferenceTextField.delegate = self
        
        let nc = NotificationCenter.default
        nc.addObserver(
            self,
            selector: #selector(keyboardChange(notification:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil)
        nc.addObserver(
            self,
            selector: #selector(keyboardChange(notification:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil)
        nc.addObserver(
            self,
            selector: #selector(keyboardChange(notification:)),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil)
    }
    
    deinit {
        let nc = NotificationCenter.default
        nc.removeObserver(
            self,
            name: UIResponder.keyboardWillShowNotification,
            object: nil)
        nc.removeObserver(
            self,
            name: UIResponder.keyboardWillHideNotification,
            object: nil)
        nc.removeObserver(
            self,
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil)
    }
    
    @IBAction func buttonPressed(_ sender: UIBarButtonItem) {
        if sender == doneButtonItem {
            if carbonTextField.layer.borderColor == UIColor.green.cgColor {
                newOrUpdateEcoDatum()
                heightTextField.resignFirstResponder()
                circumferenceTextField.resignFirstResponder()
                dismiss(animated: true, completion: nil)
            } else if carbonTextField.layer.borderColor == UIColor.red.cgColor  {
                displayAlert()
            } else {
                dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == heightTextField {
            circumferenceTextField.becomeFirstResponder()
        } else if textField == circumferenceTextField {
            if let carbonTextValue = carbonTextField.text,
                !carbonTextValue.isEmpty {
                newOrUpdateEcoDatum()
                circumferenceTextField.resignFirstResponder()
                dismiss(animated: true, completion: nil)
            } else {
                displayAlert()
            }
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let currentTextFieldValue = textField.text else {
            log.error("Unexpected. Text field should have text.")
            return false
        }
        
        let newTextValue = (currentTextFieldValue as NSString).replacingCharacters(in: range, with: string)
        
        if newTextValue == "." {
            return true
        }
        
        if let newDecimalValue = decimalValue(newTextValue: newTextValue) {
            calculateCarbon(textField: textField, newDecimalValue: newDecimalValue)
            return true
        } else if newTextValue.isEmpty {
            calculateCarbon(textField: textField, newDecimalValue: nil)
            return true
        }
        return false
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        calculateCarbon(textField: textField, newDecimalValue: nil)
        return true
    }
    
    @objc private func keyboardChange(notification: Notification) {
        let keyboardNSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
        guard let keyboardRectValue = keyboardNSValue?.cgRectValue else {
            log.warning("Failed to determine keyboard rectangular value.")
            return
        }
        
        if notification.name == UIResponder.keyboardWillShowNotification ||
            notification.name == UIResponder.keyboardWillChangeFrameNotification {
            let heightBuffer = (view.frame.height / 2) - (dataView.frame.height / 2)
            if keyboardRectValue.height > heightBuffer {
                view.frame.origin.y = -(keyboardRectValue.height - heightBuffer)
            }
        } else {
            view.frame.origin.y = 0
        }
    }
    
    private func decimalValue(newTextValue: String) -> Decimal? {
        return numberFormatter.number(from: newTextValue)?.decimalValue
    }
    
    private func calculateCarbon(textField: UITextField, newDecimalValue: Decimal?) {
        var heightInMetersOptional: Decimal?
        var circumferenceInMetersOptional: Decimal?
        
        if textField == heightTextField {
            heightInMetersOptional = newDecimalValue
            if let circumferenceTextValue = circumferenceTextField.text {
                circumferenceInMetersOptional = numberFormatter.number(from: circumferenceTextValue)?.decimalValue
            }
        } else if textField == circumferenceTextField {
            if let heightTextValue = heightTextField.text {
                heightInMetersOptional = numberFormatter.number(from: heightTextValue)?.decimalValue
            }
            circumferenceInMetersOptional = newDecimalValue
        }
        
        guard let heightInMeters = heightInMetersOptional,
            let circumferenceInMeters = circumferenceInMetersOptional else {
                carbonTextField.text = ""
                carbonTextField.layer.borderWidth = 2
                carbonTextField.layer.borderColor = UIColor.red.cgColor
                return
        }
        
        let volOfTreeMetersCubed = Decimal(0.0567) + (Decimal(0.5074) * pow(circumferenceInMeters / Decimal.pi, 2) * heightInMeters)
        let volOfTreeCentimetersCubed = volOfTreeMetersCubed * Decimal(1000000)
        let densityOfWoodGramsPerCentimetersCubed = Decimal(0.6)
        let massOfWoodGrams = Decimal(0.55) * volOfTreeCentimetersCubed * densityOfWoodGramsPerCentimetersCubed
        let massOfCarbonGrams = Decimal(0.5) * massOfWoodGrams
        let massOfCarbonKilograms = massOfCarbonGrams / Decimal(1000)
        
        carbonTextField.layer.borderWidth = 1
        carbonTextField.layer.borderColor = UIColor.green.cgColor
        carbonTextField.text = carbonFormatter.string(from: NSDecimalNumber(decimal: massOfCarbonKilograms))
    }
    
    private func displayAlert() {
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            self.dismiss(animated: true, completion: nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let alertController = UIAlertController(
            title: "Data Error",
            message: "Unable to calculate kilograms of carbon. Press OK to continue with out saving data. Press Cancel to continue entering data.",
            preferredStyle: .alert)
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    private func newOrUpdateEcoDatum() {
        ecoDatum == nil ? newEcoDatum() : updateEcoDatum()
    }
    
    private func newEcoDatum() {
        guard ecoDatum == nil else {
            log.error("EcoDatum already exists for new EcoDatum")
            return
        }
        
        guard let heightText = heightTextField.text,
            let heightDecimal = numberFormatter.number(from: heightText),
            let circumferenceText = circumferenceTextField.text,
            let circumferenceDecimal = numberFormatter.number(from: circumferenceText),
            let carbonText = carbonTextField.text,
            let carbonDecimal = carbonFormatter.number(from: carbonText) else {
                log.error("Failed to extract data from text fields")
                return
        }
    
        do {
            let dataValue = CarbonSinkDataValue(
                heightInMeters: heightDecimal.decimalValue,
                circumferenceInMeters: circumferenceDecimal.decimalValue,
                carbonInKilograms: carbonDecimal.decimalValue)
            ecoDatum = try site.newEcoDatum(
                context,
                collectionDate: Date(),
                primaryType: PrimaryType.Biotic.rawValue,
                secondaryType: SecondaryType.OrganicCarbon.rawValue,
                dataType: DataType.Carbon.rawValue,
                dataUnit: DataUnit.KilogramsOfCarbon.rawValue,
                dataValue: try JSONEncoder().encode(dataValue))
            try context.save()
        } catch let error as NSError {
            log.error("Failed to create new EcoDatum for Site \(site.name!): \(error)")
        }
    }
    
    private func updateEcoDatum() {
        guard let ecoDatum = ecoDatum else {
            log.error("EcoDatum value not set for update")
            return
        }
        
        guard let heightText = heightTextField.text,
            let heightDecimal = numberFormatter.number(from: heightText),
            let circumferenceText = circumferenceTextField.text,
            let circumferenceDecimal = numberFormatter.number(from: circumferenceText),
            let carbonText = carbonTextField.text,
            let carbonDecimal = carbonFormatter.number(from: carbonText) else {
                log.error("Failed to extract data from text fields")
                return
        }
        
        do {
            let dataValue = CarbonSinkDataValue(
                heightInMeters: heightDecimal.decimalValue,
                circumferenceInMeters: circumferenceDecimal.decimalValue,
                carbonInKilograms: carbonDecimal.decimalValue)
            ecoDatum.dataValue = try JSONEncoder().encode(dataValue)
            try context.save()
        } catch let error as NSError {
            log.error("Failed to delete EcoDatum for Site \(site.name!): \(error)")
        }
    }
    
}
