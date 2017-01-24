//
//  TrackObject.swift
//  Volumio
//
//  Created by Federico Sintucci on 26/09/16.
//  Copyright © 2016 Federico Sintucci. All rights reserved.
//

import ObjectMapper

class TrackObject: Mappable {
    var type: ItemType = .track

    var title: String?
    var name: String?
    var artist: String?
    var album: String?
    var albumArt: String?
    var volume: Int?
    var seek: Int?
    var duration: Int?
    var uri: String?
    var status: String?
    var repetition: Int?
    var shuffle: Int?
    var consume: Int?
    var service: String?
    var position: Int?
    
    required init?(map: Map) {
    }
    
    // Mappable
    func mapping(map: Map) {
        title       <- map["title"]
        name        <- map["name"]
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
        consume     <- map["consume"]
        service     <- map["service"]
        position    <- map["position"]
    }
}
