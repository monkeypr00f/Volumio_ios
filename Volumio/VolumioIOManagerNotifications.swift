//
//  VolumioIOManagerNotifications.swift
//  Volumio
//
//  Created by Michael Baumgärtner on 10.01.17.
//  Copyright © 2017 Federico Sintucci. All rights reserved.
//

import Foundation

// Notifications posted by VolumioIOManager

extension Notification.Name {
    static let connected = Notification.Name("connected")
    static let disconnected = Notification.Name("disconnected")
    static let currentTrack = Notification.Name("currentTrack")
    static let browseSources = Notification.Name("browseSources")
    static let browseLibrary = Notification.Name("browseLibrary")
    static let browseSearch = Notification.Name("browseSearch")
    static let currentQueue = Notification.Name("currentQueue")
    static let addedToQueue = Notification.Name("addedToQueue")
    static let removedfromQueue = Notification.Name("removedfromQueue")
    static let listPlaylists = Notification.Name("listPlaylists")
    static let addedToPlaylist = Notification.Name("addedToPlaylist")
    static let removedFromPlaylist = Notification.Name("removedFromPlaylist")
    static let playlistPlaying = Notification.Name("playlistPlaying")
    static let playlistDeleted = Notification.Name("playlistDeleted")
    static let browsePlugins = Notification.Name("browsePlugins")
    static let browseNetwork = Notification.Name("browseNetwork")
    static let browseWifi = Notification.Name("browseWifi")
}
