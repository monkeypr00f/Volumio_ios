//
//  LibraryObject.swift
//  Volumio-iOS
//
//  Created by Federico Sintucci on 10/10/16.
//  Copyright © 2016 Federico Sintucci. All rights reserved.
//

import UIKit
import ObjectMapper

class LibraryObject: Mappable {
    var title: String?
    var artist: String?
    var album: String?
    var albumArt: String?
    var uri: String?
    var service: String?
    var type: String?
    
    required init?(map: Map) {
        
    }
    
    // Mappable
    func mapping(map: Map) {
        title       <- map["title"]
        artist      <- map["artist"]
        album       <- map["album"]
        albumArt    <- map["albumart"]
        uri         <- map["uri"]
        service     <- map["service"]
        type        <- map["type"]
    }
}
