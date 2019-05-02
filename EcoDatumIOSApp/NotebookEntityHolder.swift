//
//  NotebookEntityHolder.swift
//  EcoDatumIOSApp
//
//  Created by Kenneth Wingerden on 5/2/19.
//  Copyright © 2019 Kenneth Wingerden. All rights reserved.
//

import CoreData
import EcoDatumCoreData
import EcoDatumService
import Foundation

protocol NotebookEntityHolder {
    
    var notebook: NotebookEntity! { set get }
    
}
