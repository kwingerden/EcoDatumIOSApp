//
//  CarbonSinkDataCodable.swift
//  EcoDatumIOSApp
//
//  Created by Kenneth Wingerden on 5/3/19.
//  Copyright © 2019 Kenneth Wingerden. All rights reserved.
//

import Foundation

struct CarbonSinkDataValue: Codable {
    
    let heightInMeters: Decimal
    let circumferenceInMeters: Decimal
    let carbonInKilograms: Decimal
    
}
