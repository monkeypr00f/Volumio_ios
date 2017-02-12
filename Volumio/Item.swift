//
//  Item.swift
//  Volumio
//
//  Created by Michael Baumgärtner on 23.01.17.
//  Copyright © 2017 Federico Sintucci. All rights reserved.
//

import Foundation

/**
 This represents a Volumio item. It can be a song, a playlist, a folder, and so forth.
*/
protocol Item {
    /// Type of this Volumio item (track, song, playlist, folder, ...)
    var type: ItemType { get }

    /// Title for this item.
    var title: String? { get }
    /// Name for this item. Tracks have names, for all other items this is nil.
    var name: String? { get }

    /// Artist for this item. Maybe nil for some types.
    var artist: String? { get }
    /// Album for this item. Maybe nil for some types.
    var album: String? { get }
    /// Album art url string for this item. Maybe nil for some types.
    var albumArt: String? { get }
}

enum ItemType: String {
    case title
    case track
    case folder
    case playlist
    case song
    case cuesong
    case webradio
    case mywebradio
    case radio_favourites = "radio-favourites"
    case radio_category = "radio-category"
    case unknown

    var isTrack: Bool {
        return self == .track
    }

    var isSong: Bool {
        return self == .song || self == .cuesong
    }

    var isRadio: Bool {
        return self == .webradio || self == .mywebradio
    }

}

// MARK: - Localization

// Localized strings for this item. Note: Some of this methods don’t really localize anything, but return a resonable default string if data is missing.

extension Item {

    /// Returns the title of this item or an empty string if title data is missing.
    var localizedTitle: String {
        return title ?? name ?? ""
    }

    /// Returns the artist for this item or an empty string if artist data is missing.
    var localizedArtist: String {
        return artist ?? ""
    }

    /// Returns the album of this item or an empty string if album data is missing.
    var localizedAlbum: String {
        return album ?? ""
    }

    /// Returns a combined string with artist and album information for this item.
    var localizedArtistAndAlbum: String {
        if let artist = artist, !artist.isBlank {
            if let album = album, !album.isBlank {
                return "\(artist) - \(album)"
            } else {
                return "\(artist) - No album"
            }
        } else {
            return album ?? ""
        }
    }

}
