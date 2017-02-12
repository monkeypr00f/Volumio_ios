//
//  UIImageView+Item.swift
//  Volumio
//
//  Created by Michael Baumgärtner on 11.02.17.
//  Copyright © 2017 Federico Sintucci. All rights reserved.
//

import UIKit

import Kingfisher

extension UIImageView {

    /**
        Sets the image to the album art of the specified item.
        - Parameter item: Volumio item.
        - Note: Images will be cached per item. It is preferred to use this method instead of retrieving images directly.
     */
    func setAlbumArt(for item: Item) {
        let defaultAlbumArt = UIImage.defaultImage(for: item)

        if item.albumArt?.range(of:"http") != nil{
            self.kf.setImage(
                with: URL(string: item.albumArt!),
                placeholder: defaultAlbumArt,
                options: [.transition(.fade(0.2))]
            )
        } else {
            if item.type.isTrack || item.type.isSong {
                // FIXME: this will fail for songs without artist or album field
                LastFMService.shared.albumGetImageURL(
                    artist: item.artist!,
                    album: item.album!,
                    completion: { (albumUrl) in
                        if let albumUrl = albumUrl {
                            DispatchQueue.main.async {
                                self.kf.setImage(
                                    with: albumUrl,
                                    placeholder: defaultAlbumArt,
                                    options: [.transition(.fade(0.2))]
                                )
                            }
                        } else {
                            self.image = defaultAlbumArt
                        }
                    }
                )
            } else {
                self.image = defaultAlbumArt
            }
        }
    }

}

extension UIImage {

    class func defaultImage(for item: Item) -> UIImage {
        var defaultName: String
        switch item.type {
        case _ where item.type.isSong:
            defaultName = "background"
        case _ where item.type.isTrack:
            defaultName = "background"
        case _ where item.type.isRadio:
            defaultName = "radio"
        case .folder:
            defaultName = "folder"
        default:
            defaultName = "background"
        }
        guard let defaultImage = UIImage(named: defaultName) else {
            fatalError("default image for album art missing")
        }
        return defaultImage
    }

}
