//
//  CoreDataContextHolder.swift
//  EcoDatumIOSApp
//
//  Created by Kenneth Wingerden on 3/27/19.
//  Copyright © 2019 Kenneth Wingerden. All rights reserved.
//

import CoreData
import Foundation

protocol CoreDataContextHolder {
    
    var context: NSManagedObjectContext! { set get }
    
}
