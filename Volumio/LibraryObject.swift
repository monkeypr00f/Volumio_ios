//
//  LibraryObject.swift
//  Volumio
//
//  Created by Federico Sintucci on 10/10/16.
//  Copyright © 2016 Federico Sintucci. All rights reserved.
//

import ObjectMapper

class LibraryObject: Mappable, Item {
    var type: ItemType = .unknown
    
    var title: String?
    var name: String?
    var artist: String?
    var album: String?
    var albumArt: String?
    
    var uri: String?
    var service: String?
    
    required init?(map: Map) {
    }
    
    // Mappable
    func mapping(map: Map) {
        type        <- (map["type"], ItemTypeTransform())
        
        title       <- map["title"]
        artist      <- map["artist"]
        album       <- map["album"]
        albumArt    <- map["albumart"]
        uri         <- map["uri"]
        service     <- map["service"]
    }
}

/// Transform for JSON mapping from string to `ItemType` and vice versa.
class ItemTypeTransform: TransformType {
    public typealias Object = ItemType
    public typealias JSON = String
    
    public init() {}
    
    /// Transforms a string from JSON into `ItemType`. Unknown strings will become `ItemType.unknown`.
    open func transformFromJSON(_ value: Any?) -> ItemType? {
        if let typeString = value as? String {
            return ItemType(rawValue: typeString) ?? .unknown
        }
        return .unknown
    }
    
    open func transformToJSON(_ value: ItemType?) -> String? {
        if let type = value {
            return type.rawValue
        }
        return nil
    }
}
