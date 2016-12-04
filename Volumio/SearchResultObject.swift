//
//  SearchResultObject.swift
//  Volumio
//
//  Created by Federico Sintucci on 22/10/16.
//  Copyright © 2016 Federico Sintucci. All rights reserved.
//

import UIKit
import ObjectMapper

class SearchResultObject: Mappable {
    var items: [LibraryObject]?
    var title: String?
    
    required init?(map: Map) {
        
    }
    
    // Mappable
    func mapping(map: Map) {
        items      <- map["items"]
        title      <- map["title"]
    }
}
