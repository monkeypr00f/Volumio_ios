//
//  PluginObject.swift
//  Volumio
//
//  Created by Federico Sintucci on 17/10/16.
//  Copyright © 2016 Federico Sintucci. All rights reserved.
//

import UIKit
import ObjectMapper

class PluginObject: Mappable {
    var name: String?
    var prettyName: String?
    var version: String?
    var enabled: Int?
    var active: Int?
    var category: String?
    
    required init?(map: Map) {
        
    }
    
    // Mappable
    func mapping(map: Map) {
        name        <- map["name"]
        prettyName  <- map["prettyName"]
        version     <- map["version"]
        enabled     <- map["enabled"]
        active      <- map["active"]
        category    <- map["category"]
    }
}
