//
//  SitePhotoViewController.swift
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

class SitePhotoViewController: UIViewController {
    
    @IBOutlet weak var siteImageView: UIImageView!
    
    @IBOutlet weak var cameraButton: UIButton!
    
    @IBOutlet weak var libraryButton: UIButton!
    
    private var context: NSManagedObjectContext!
    
    private var siteName: String!
    
    private var notebookName: String!
    
    private var targetImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func setContext(_ context: NSManagedObjectContext,
                    with siteName: String,
                    in notebookName: String,
                    target imageView: UIImageView) {
        self.context = context
        self.siteName = siteName
        self.notebookName = notebookName
        self.targetImageView = imageView
    }
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        switch sender {
        case cameraButton:
            showImagePickerController(.camera)
        case libraryButton:
            showImagePickerController(.photoLibrary)
        default:
            log.error("Unexpected sender \(sender)")
        }
    }
    
    @IBAction func tapView(_ gestureRecognizer : UITapGestureRecognizer) {
        targetImageView.image = siteImageView.image
        dismiss(animated: true, completion: nil)
    }
    
    private func showImagePickerController(_ sourceType: UIImagePickerController.SourceType) {
        if sourceType == .camera {
            guard UIImagePickerController.isCameraDeviceAvailable(.rear) else {
                log.error("No rear facing camera is available")
                return
            }
        }
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
}

extension SitePhotoViewController: UINavigationControllerDelegate {
    
}

extension SitePhotoViewController: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        var image: UIImage = siteImageView.image!
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            image = editedImage
        } else if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            image = pickedImage
        }
        siteImageView.image = image
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}
