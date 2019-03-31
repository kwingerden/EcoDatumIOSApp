//
//  SitePhotoViewController.swift
//  EcoDatumIOSApp
//
//  Created by Kenneth Wingerden on 3/29/19.
//  Copyright © 2019 Kenneth Wingerden. All rights reserved.
//

import CoreData
import EcoDatumCoreData
import EcoDatumModel
import EcoDatumService
import Foundation
import MobileCoreServices
import UIKit

class SitePhotoViewController: UIViewController {
    
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var siteImageView: UIImageView!
    
    @IBOutlet weak var cameraButton: UIButton!
    
    @IBOutlet weak var libraryButton: UIButton!
    
    @IBOutlet weak var albumsButton: UIButton!
    
    private var context: NSManagedObjectContext!
    
    private var siteName: String!
    
    private var notebookName: String!
    
    private var originalSiteImage: UIImage!
    
    private var completion: (() -> Void)!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = siteName
        siteImageView.image = originalSiteImage
    }
    
    func setContext(_ context: NSManagedObjectContext,
                    with siteName: String,
                    with originalSiteImage: UIImage? = nil,
                    in notebookName: String,
                    completion: @escaping () -> Void = {}) {
        self.context = context
        self.siteName = siteName
        if let originalSiteImage = originalSiteImage {
            self.originalSiteImage = originalSiteImage
        } else {
            self.originalSiteImage = UIImage(named: "PlaceHolderImage")
        }
        self.notebookName = notebookName
        self.completion = completion
    }
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        switch sender {
        case cameraButton:
            showImagePickerController(.camera)
        case libraryButton:
            showImagePickerController(.photoLibrary)
        case albumsButton:
            showImagePickerController(.savedPhotosAlbum)
        case cancelButton:
            dismiss()
        case saveButton:
            saveImage()
        default:
            log.error("Unexpected sender \(sender)")
        }
    }
    
    private func showImagePickerController(_ sourceType: UIImagePickerController.SourceType) {
        guard UIImagePickerController.isSourceTypeAvailable(sourceType) else {
            log.error("Source type \(sourceType) is not available")
            return
        }
        
        if sourceType == .camera && !UIImagePickerController.isCameraDeviceAvailable(.rear) {
            log.error("No rear facing camera is available for camera source")
            return
        }
        
        let imageType = String(kUTTypeImage)
        guard let mediaTypes = UIImagePickerController.availableMediaTypes(for: sourceType),
            mediaTypes.contains(imageType)  else {
                log.error("No rear facing camera is available for camera source")
                return
        }
        
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        imagePicker.mediaTypes = [imageType]
        imagePicker.sourceType = sourceType
        
        if sourceType == .camera {
            imagePicker.cameraCaptureMode = .photo
            imagePicker.cameraDevice = .rear
            imagePicker.showsCameraControls = true
        }
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    private func saveImage() {
        var site: SiteEntity?
        do {
            site = try SiteEntity.find(context, with: siteName, in: notebookName)
        } catch let error as NSError {
            log.error("Error while finding SiteEntity \(siteName!) in \(notebookName!): \(error)")
            dismiss()
            return
        }
        
        guard site != nil else {
            log.error("Failed to find SiteEntity \(siteName!) in \(notebookName!)")
            dismiss()
            return
        }
        
        guard let newSiteImage = siteImageView.image else {
            log.error("Failed to obtain new site image for site \(siteName!) in \(notebookName!)")
            dismiss()
            return
        }
        
        guard let dataValue = newSiteImage.base64EncodedJPEG() else {
            log.error("Failed to base64 encode site image for site \(siteName!) in \(notebookName!)")
            dismiss()
            return
        }
        
        let ecoDatum = EcoDatum(primaryType: PrimaryType.Biotic,
                                secondaryType: SecondaryType.Photo,
                                dataType: DataType.JPEG,
                                dataValue: dataValue)
        do {
            let ecoDatumEntity = try EcoDatumEntity.new(context,
                                                        with: siteName!,
                                                        in: notebookName!,
                                                        ecoDatum: ecoDatum)
            site!.addToEcoData(ecoDatumEntity)
            try site!.save()
        } catch let error as NSError {
            log.error("Failed to save EcoDatumEntiy for site \(siteName!) in \(notebookName!): \(error)")
        }
        
        dismiss()
    }
    
    private func dismiss() {
        completion()
        dismiss(animated: true, completion: nil)
    }
    
}

extension SitePhotoViewController: UINavigationControllerDelegate {
    
}

extension SitePhotoViewController: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        var image: UIImage = siteImageView.image ?? UIImage(named: "PlaceholderImage")!
        if let editedImage = info[.editedImage] as? UIImage {
            image = editedImage
        } else if let pickedImage = info[.originalImage] as? UIImage {
            image = pickedImage
        }
        siteImageView.image = image
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}
