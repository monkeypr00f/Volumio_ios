//
//  VolumioIOEvents.swift
//  Volumio
//
//  Created by Michael Baumgärtner on 11.01.17.
//  Copyright © 2017 Federico Sintucci. All rights reserved.
//

import SocketIO

// Events for VolumioIOManager

enum VolumioIOEvent: String {
    case connect
    case reconnect
    case getState
    case pushState
    case setRepeat
    case setRandom
    case setConsume
    case play
    case stop
    case pause
    case prev
    case next
    case volume
    case search
    case getBrowseSources
    case pushBrowseSources
    case browseLibrary
    case pushBrowseLibrary
    case getQueue
    case addToQueue
    case removeFromQueue
    case clearQueue
    case moveQueue
    case pushQueue
    case listPlaylist
    case pushListPlaylist
    case addToPlaylist
    case removeFromPlaylist
    case createPlaylist
    case deletePlaylist
    case playPlaylist
    case pushCreatePlaylist
    case getInstalledPlugins
    case pushInstalledPlugins
    case pluginManager
    case getInfoNetwork
    case pushInfoNetwork
    case getWirelessNetworks
    case pushWirelessNetworks
    case pushToastMessage
    case shutdown
    case reboot
}

extension SocketIOClient {

    @discardableResult
    func on(_ event: VolumioIOEvent, callback: @escaping NormalCallback) -> UUID {
        return on(event.rawValue, callback: callback)
    }

    @discardableResult
    func once(_ event: VolumioIOEvent, callback: @escaping NormalCallback) -> UUID {
        return once(event.rawValue, callback: callback)
    }

    func emit(_ event: VolumioIOEvent, _ items: SocketData...) {
        emit(event.rawValue, with: items)
    }

}
