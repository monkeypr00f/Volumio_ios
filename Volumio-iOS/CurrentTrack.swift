//
//  CurrentTrack.swift
//  Volumio-iOS
//
//  Created by Federico Sintucci on 26/09/16.
//  Copyright © 2016 Federico Sintucci. All rights reserved.
//

import UIKit
import ObjectMapper

class CurrentTrack: Mappable {
    var title: String?
    var artist: String?
    var album: String?
    var albumArt: String?
    var volume: Int?
    var seek: Int?
    var duration: Int?
    var uri: String?
    var status: String?
    var service: String?
    
    required init?(map: Map) {
        
    }
    
    // Mappable
    func mapping(map: Map) {
        title       <- map["title"]
        artist      <- map["artist"]
        album       <- map["album"]
        albumArt    <- map["albumart"]
        volume      <- map["volume"]
        seek        <- map["seek"]
        duration    <- map["duration"]
        uri         <- map["uri"]
        status      <- map["status"]
        service     <- map["service"]
    }
}
