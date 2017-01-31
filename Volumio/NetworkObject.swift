//
//  NetworkObject.swift
//  Volumio
//
//  Created by Federico Sintucci on 21/10/16.
//  Copyright © 2016 Federico Sintucci. All rights reserved.
//

import ObjectMapper

class NetworkObject: Mappable {
    var ip: String?
    var inline: String?
    var signal: Int?
    var speed: String?
    var ssid: String?
    var status: String?
    var type: String?
    
    required init?(map: Map) {
    }
    
    // Mappable
    func mapping(map: Map) {
        ip          <- map["ip"]
        inline      <- map["inline"]
        signal      <- map["signal"]
        speed       <- map["speed"]
        ssid        <- map["ssid"]
        status      <- map["status"]
        type        <- map["type"]
    }
}

extension NetworkObject:
    CustomStringConvertible, CustomDebugStringConvertible, DefaultStringConvertible {
}
