//
//  SourceObject.swift
//  Volumio
//
//  Created by Federico Sintucci on 14/10/16.
//  Copyright © 2016 Federico Sintucci. All rights reserved.
//

import ObjectMapper

class SourceObject: Mappable {
    var name: String?
    var plugin_name: String?
    var plugin_type: String?
    var uri: String?
    
    required init?(map: Map) {
    }
    
    // Mappable
    func mapping(map: Map) {
        name            <- map["name"]
        plugin_name     <- map["plugin_name"]
        plugin_type     <- map["plugin_type"]
        uri             <- map["uri"]
    }
}
