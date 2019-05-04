//
//  CarbonSinkDataViewController.swift
//  EcoDatumIOSApp
//
//  Created by Kenneth Wingerden on 5/1/19.
//  Copyright © 2019 Kenneth Wingerden. All rights reserved.
//

import CoreData
import EcoDatumCoreData
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
        nf.maximumFractionDigits = 2
        return nf
    }()
    
    private let allowableCharacterSet = CharacterSet(charactersIn: ".0123456789")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "\(site.name!) - Data"
        
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
            dismiss(animated: true, completion: nil)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == heightTextField {
            circumferenceTextField.becomeFirstResponder()
        } else if textField == circumferenceTextField {
            circumferenceTextField.resignFirstResponder()
            dismiss(animated: true, completion: nil)
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let currentTextFieldValue = textField.text else {
            log.error("Unexpected. Text field should have text.")
            return false
        }
        
        let newTextValue = (currentTextFieldValue as NSString).replacingCharacters(in: range, with: string)
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
        carbonTextField.text = numberFormatter.string(from: NSDecimalNumber(decimal: massOfCarbonKilograms))
    }
}
