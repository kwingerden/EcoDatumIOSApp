//
//  SiteMasterCellView.swift
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
import UIKit

class SiteMasterTableViewCell: UITableViewCell {
    
    static let CELL_HEIGHT: CGFloat = 276
    
    @IBOutlet weak var siteNameLabel: UILabel!
    
    @IBOutlet weak var siteImageView: UIImageView!
    
    @IBOutlet weak var dateTextField: UITextField!
    
    @IBOutlet weak var latitudeTextField: UITextField!
    
    @IBOutlet weak var longitudeTextField: UITextField!
    
    var indexPath: IndexPath!
    
    private var context: NSManagedObjectContext!
    
    private var siteName: String!
    
    private var notebookName: String!
    
    private var performSegue: ((String, Any?) -> Void)!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setContext(_ context: NSManagedObjectContext,
                    indexPath: IndexPath,
                    with siteName: String,
                    in notebookName: String,
                    performSegue: @escaping (String, Any?) -> Void) throws {
        self.context = context
        self.indexPath = indexPath
        self.siteName = siteName
        self.notebookName = notebookName
        self.performSegue = performSegue
        
        guard let site = try SiteEntity.find(context, with: siteName, in: notebookName) else {
            log.error("Failed to find Site \(siteName) in Notebook \(notebookName)")
            return
        }
        
        guard let name = site.name, let createdDate = site.createdDate else {
            log.error("Failed to load properties for Site \(siteName) in Notebook \(notebookName)")
            return
        }
        
        siteNameLabel.text = name
        dateTextField.text = createdDate.mediumFormatString()
        
        siteImageView.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(siteImageViewTapped)))

        do {
            let ecoDatum = try EcoDatumEntity.first(context,
                                                    with: siteName,
                                                    in: notebookName,
                                                    with: .Site,
                                                    with: .Photo,
                                                    with: .JPEG)
            if let ecoDatum = ecoDatum,
                let dataValue = ecoDatum.dataValue,
                let base64Encoded = String(data: dataValue, encoding: .utf8),
                let image = base64Encoded.base64DecodeUIImage() {
                siteImageView.image = image
            } else {
                siteImageView.image = UIImage(named: "PlaceholderImage")
            }
        } catch let error as NSError {
            log.error("Failed to find first site photo in Site \(siteName) in \(notebookName): \(error)")
            siteImageView.image = UIImage(named: "PlaceholderImage")
        }
    }
    
    @objc func siteImageViewTapped() {
        log.debug("siteImageViewTapped")
        performSegue("choosePhoto", self)
    }

}

extension SiteMasterTableViewCell: UIImagePickerControllerDelegate {
    
}

extension SiteMasterTableViewCell: UINavigationControllerDelegate {
    
}
