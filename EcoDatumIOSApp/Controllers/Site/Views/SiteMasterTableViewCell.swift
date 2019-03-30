//
//  SiteMasterCellView.swift
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

class SiteMasterTableViewCell: UITableViewCell {
    
    static let CELL_HEIGHT: CGFloat = 276
    
    @IBOutlet weak var siteNameLabel: UILabel!
    
    @IBOutlet weak var siteImageView: UIImageView!
    
    @IBOutlet weak var dateTextField: UITextField!
    
    private var context: NSManagedObjectContext!
    
    private var siteName: String!
    
    private var notebookName: String!
    
    private var performSegue: ((String, Any?) -> Void)!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setContext(_ context: NSManagedObjectContext,
                    with siteName: String,
                    in notebookName: String,
                    performSegue: @escaping (String, Any?) -> Void) throws {
        self.context = context
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
        
        siteImageView.isUserInteractionEnabled = true
        siteImageView.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(siteImageViewTapped)))
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
