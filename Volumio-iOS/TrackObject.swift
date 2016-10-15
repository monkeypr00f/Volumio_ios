//
//  TrackObject.swift
//  Volumio-iOS
//
//  Created by Federico Sintucci on 26/09/16.
//  Copyright © 2016 Federico Sintucci. All rights reserved.
//

import UIKit
import ObjectMapper

class TrackObject: Mappable {
    var title: String?
    var artist: String?
    var album: String?
    var albumArt: String?
    var volume: Int?
    var seek: Int?
    var duration: Int?
    var uri: String?
    var status: String?
    var repetition: String?
    var shuffle: String?
    var service: String?
    var position: Int?
    
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
        repetition  <- map["repeat"]
        shuffle     <- map["random"]
        service     <- map["service"]
        position    <- map["position"]
    }
}
