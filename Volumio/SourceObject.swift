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
    var uri: String?
    var pluginName: String?
    var pluginType: String?

    required init?(map: Map) {
    }

    // Mappable
    func mapping(map: Map) {
              name <- map["name"]
               uri <- map["uri"]
        pluginName <- map["plugin_name"]
        pluginType <- map["plugin_type"]
    }
}
