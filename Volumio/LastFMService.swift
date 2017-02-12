//
//  LastFMService.swift
//  Volumio
//
//  Created by Federico Sintucci on 29/09/16.
//  Copyright © 2016 Federico Sintucci. All rights reserved.
//

import Foundation

import Alamofire
import SwiftyJSON

/**
 Manager to get metadata and tracklist for an album from Last.fm webservice.
*/
class LastFMService {

    static let shared = LastFMService()

    private var queue: DispatchQueue!

    init() {
        queue = DispatchQueue(
            label: "LastFMServiceQueue",
            qos: .utility,
            attributes: .concurrent
        )
    }

    /**
        Asynchronously requests an URL to the album image for the specified artist and the specified album from Last.fm webservice.
        - Parameter artist: Name of the artist.
        - Parameter album: Title of the album.
        - Parameter completionHandler: Callback, which will be called with a cover image url on success or nil otherwise.
        - Note: While Last.fm offers various sizes of the cover image, this method will only return the url to the cover image of size 'large'.
    */
    func albumGetImageURL(artist: String, album: String, completion: @escaping (URL?) -> Void) {
        let albumGetInfo = LastFMRequest.albumGetInfo(artist: artist, album: album)

        Alamofire.request(albumGetInfo)
            .validate()
            .responseJSON(queue: queue) { (response) in
                switch response.result {
                case .success(let value):
                    let infoJSON = JSON(string: value as Any)

                    // find album image json for image of size 'large'
                    let imageJSON = infoJSON["album"]["image"].arrayValue.first(where: { (json) in
                        return json["size"] == "large"
                    })

                    // get url from album image json
                    var imageURL: URL? = nil
                    if let urlString = imageJSON?["#text"].string {
                        imageURL = URL(string: urlString)
                    }
                    completion(imageURL)
                case .failure(_):
                    completion(nil)
                }
            }
    }

}

/// Request router for Last.fm webservice.
enum LastFMRequest: URLRequestConvertible {

    case albumGetInfo(artist: String, album: String)

    static let baseURLString = "http://ws.audioscrobbler.com/2.0/"

    static let apiKey = "6ebfdd6251d6554e578b03c642d93ada"

    func asURLRequest() throws -> URLRequest {
        let result: (path: String, parameters: Parameters) = {
            switch self {
            case let .albumGetInfo(artist, album):
                return ("/", [
                    "method": "album.getinfo",
                    "artist": artist,
                    "album": album,
                    "format": "json",
                    "api_key": LastFMRequest.apiKey
                ])
            }
        }()
        let url = try LastFMRequest.baseURLString.asURL()
        let urlRequest = URLRequest(url: url.appendingPathComponent(result.path))
        return try URLEncoding.default.encode(urlRequest, with: result.parameters)
    }

}
