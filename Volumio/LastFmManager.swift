//
//  LastFmManager.swift
//  Volumio
//
//  Created by Federico Sintucci on 29/09/16.
//  Copyright © 2016 Federico Sintucci. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class LastFmManager: NSObject {
    
    static let sharedInstance = LastFmManager()
    private var queue: DispatchQueue!
    
    override init() {
        super.init()
        self.queue = DispatchQueue(label: "lastFmQueue", qos: .utility, attributes: .concurrent)
    }
    
    func getAlbumArt(artist:String, album:String, completionHandler:@escaping (String?) -> ()) {
        
        let url = "http://ws.audioscrobbler.com/2.0/?method=album.getinfo&api_key=6ebfdd6251d6554e578b03c642d93ada&artist=\(artist)&album=\(album)&format=json"
        let lastFmUrl = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        Alamofire.request(lastFmUrl!).responseJSON(queue: queue, options: .allowFragments) { (response) in
            let json = JSON(string: response.result.value as Any)
            var cover: String?
            if let albumCover = json["album"]["image"][2]["#text"].string {
                cover = albumCover
            }
            completionHandler(cover)
        }
    }
}
