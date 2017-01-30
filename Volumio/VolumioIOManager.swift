//
//  VolumioIOManager.swift
//  Volumio
//
//  Created by Federico Sintucci on 21/09/16.
//  Copyright © 2016 Federico Sintucci. All rights reserved.

import SocketIO

import ObjectMapper
import SwiftyJSON

class VolumioIOManager: NSObject {
    
    static let shared = VolumioIOManager()
    
    private var socket: SocketIOClient? = nil
    
    var currentPlayer: Player?
    
    var currentTrack: TrackObject?
    var currentQueue: [TrackObject]?
    var currentSources : [SourceObject]?
    var currentLibrary: [LibraryObject]?
    var currentSearch: [SearchResultObject]?
    var currentPlaylists: [Any]?
    
    var installedPlugins: [PluginObject]?
    
    var connectedNetwork: [NetworkObject]?
    var wirelessNetwork: [NetworkObject]?
    
    var isConnected: Bool {
        return socket != nil && socket!.status == .connected
    }
    var isConnecting: Bool {
        return socket != nil && socket!.status == .connecting
    }
    
    // MARK: - manage connection
    
    /**
        Establishes a connection to the player. This is a no-op if this is already done or currently ongoing.
    */
    func establishConnection() {
        guard let socket = socket else { return }
        
        socket.connect(timeoutAfter: 10) {
            NotificationCenter.default.post(name: .disconnected, object: nil)
        }
        
        socket.on(.connect) { data, ack in
            NotificationCenter.default.post(name: .connected, object: nil)

            self.getState()
        }
        
        socket.on(.pushState) { data, ack in
            guard let json = data[0] as? [String: Any] else { return }
            
            self.currentTrack = Mapper<TrackObject>().map(JSONObject: json)
            NotificationCenter.default.post(name: .currentTrack, object: self.currentTrack)
        }
    }
	
    /**
        Connects to the player with the specified name.
     
        - parameter player: Player to connect to.
        - parameter setDefault: If `true`, stores the specified player as default. Defaults to `false`.
    */
    func connect(to player: Player, setDefault: Bool = false) {
        closeConnection()
        
        if setDefault {
            Defaults[.selectedPlayer] = player
        }

        currentPlayer = player
        socket = SocketIOClient(for: player)
        establishConnection()
    }
    
    /**
        Connects to the current player.
    */
    func connectCurrent() {
        closeConnection()
        
        if let player = currentPlayer {
            connect(to: player)
        }
        else {
            isDisconnected()
        }
    }

    /**
        Connects to the default player.
    */
    func connectDefault() {
        closeConnection()

        if let player = Defaults[.selectedPlayer] {
            connect(to: player)
        }
        else {
            isDisconnected()
        }
    }
    
    /**
        Closes the connection to the player.
    */
    func disconnect(unsetDefault: Bool = false) {
        if unsetDefault {
            Defaults.remove(.selectedPlayer)
        }

        closeConnection()
        
        isDisconnected()
    }
    
    func closeConnection() {
        if let socket = socket {
            socket.disconnect()

            self.socket = nil
        }
    }
    
    private func isDisconnected() {
        NotificationCenter.default.post(name: .disconnected, object: nil)
    }

    // MARK: - manage playback
    
    func play() {
        guard let socket = socket else { return }
        socket.emit(.play)
    }

    func stop() {
        guard let socket = socket else { return }
        socket.emit(.stop)
    }
    
    func pause() {
        guard let socket = socket else { return }
        socket.emit(.pause)
    }
    
    func playPrevious() {
        guard let socket = socket else { return }
        socket.emit(.prev)
    }
    
    func playNext() {
        guard let socket = socket else { return }
        socket.emit(.next)
    }
    
    func playTrack(position: Int) {
        guard let socket = socket else { return }
        socket.emit(.play, ["value": position])
        getState()
    }
    
    func setVolume(value: Int) {
        guard let socket = socket else { return }
        socket.emit(.volume, value)
    }
    
    func getState() {
        guard let socket = socket else { return }
        socket.emit(.getState)
    }
    
    // MARK: - manage sources
    
    func browseSources() {
        guard let socket = socket else { return }
        socket.emit(.getBrowseSources)
        socket.once(.pushBrowseSources) { data, ack in
            let json = JSON(data)
            if let sources = json[0].arrayObject {
                self.currentSources = Mapper<SourceObject>().mapArray(JSONObject: sources)
                NotificationCenter.default.post(name: .browseSources, object: self.currentSources)
            }
        }
    }
    
    func browseLibrary(uri: String) {
        guard let socket = socket else { return }
        socket.emit(.browseLibrary, ["uri":uri])
        socket.once(.pushBrowseLibrary) { data, ack in
            let json = JSON(data)
            if let items = json[0]["navigation"]["lists"][0]["items"].arrayObject {
                self.currentLibrary = Mapper<LibraryObject>().mapArray(JSONObject: items)
                NotificationCenter.default.post(name: .browseLibrary, object: self.currentLibrary)
            }
        }
    }
    
    func browseSearch(text: String) {
        guard let socket = socket else { return }
        socket.emit(.search, ["type": "", "value": text])
        socket.once(.pushBrowseLibrary) { data, ack in
            let json = JSON(data)
            if let items = json[0]["navigation"]["lists"].arrayObject {
                self.currentSearch = Mapper<SearchResultObject>().mapArray(JSONObject: items)
                NotificationCenter.default.post(name: .browseSearch, object: self.currentSearch)
            }
        }
    }
    
    func addToQueue(uri: String, title: String, service: String) {
        guard let socket = socket else { return }
        socket.emit(.addToQueue, ["uri":uri, "title":title, "service":service])
        socket.once(.pushQueue) {data, ack in
            NotificationCenter.default.post(name: .addedToQueue, object: title)
        }
    }
    
    func clearAndPlay(uri: String, title: String, service: String) {
        guard let socket = socket else { return }
        socket.emit(.clearQueue)
        socket.once(.pushQueue) { [unowned socket] data, ack in
            if let json = data[0] as? [[String:Any]] {
                if json.count == 0 {
                    socket.emit(.addToQueue, ["uri": uri, "title": title, "service": service])
                    socket.once(.pushQueue) {data, ack in
                        self.playTrack(position: 0)
                    }
                }
            }
        }
    }
    
    func addAndPlay(uri: String, title: String, service: String) {
        guard let socket = socket else { return }
        getQueue()
        socket.once(.pushQueue) { [unowned socket] data, ack in
            if let queryItems = self.currentQueue?.count {
                socket.emit(.addToQueue, ["uri": uri, "title": title, "service": service])
                socket.once(.pushQueue) {data, ack in
                    self.playTrack(position: queryItems)
                }
                NotificationCenter.default.post(name: .addedToQueue, object: title)
            }
        }
    }
    
    
    // MARK: - manage queue
    
    func getQueue() {
        guard let socket = socket else { return }
        socket.emit(.getQueue)
        socket.once(.pushQueue) {data, ack in
            if let json = data[0] as? [[String:Any]] {
                self.currentQueue = Mapper<TrackObject>().mapArray(JSONObject: json)
                NotificationCenter.default.post(name: .currentQueue, object: self.currentQueue)
            }
        }
    }
    
    func sortQueue(from: Int, to: Int) {
        guard let socket = socket else { return }
        socket.emit(.moveQueue, ["from": "\(from)", "to": "\(to)"])
        getQueue()
    }
    
    func removeFromQueue(position: Int) {
        guard let socket = socket else { return }
        socket.emit(.removeFromQueue, ["value": "\(position)"])
        socket.once(.pushToastMessage) { data, ack in
            NotificationCenter.default.post(name: .removedfromQueue, object: nil)
        }
    }
    
    func toggleRepeat(value: Int) {
        guard let socket = socket else { return }
        socket.emit(.setRepeat, ["value": value])
    }
    
    func toggleRandom(value: Int) {
        guard let socket = socket else { return }
        socket.emit(.setRandom, ["value": value])
    }
    
    func toggleConsume(value: Int) {
        guard let socket = socket else { return }
        socket.emit(.setConsume, ["value": value])
    }
    
    func clearQueue() {
        guard let socket = socket else { return }
        stop()
        socket.emit(.clearQueue)
        socket.once(.pushQueue) {data, ack in
            self.getQueue()
        }
    }
    
    // MARK: - manage playlists
    
    func listPlaylist() {
        guard let socket = socket else { return }
        socket.emit(.listPlaylist)
        socket.once(.pushListPlaylist) {data, ack in
            let json = JSON(data)
            if let items = json[0].arrayObject {
                self.currentPlaylists = items
                NotificationCenter.default.post(name: .listPlaylists, object: self.currentPlaylists)
            }
        }
    }
    
    func addToPlaylist(name: String, uri: String, service: String) {
        guard let socket = socket else { return }
        socket.emit(.addToPlaylist, ["name": name, "uri":uri, "service":service])
        socket.once(.pushToastMessage) {data, ack in
            NotificationCenter.default.post(name: .addedToPlaylist, object: name)
        }
    }
    
    func removeFromPlaylist(name: String, uri: String, service: String) {
        guard let socket = socket else { return }
        socket.emit(.removeFromPlaylist, ["name": name, "uri":uri, "service":service])
        socket.once(.pushToastMessage) {data, ack in
            NotificationCenter.default.post(name: .removedFromPlaylist, object: name)
        }
    }
    
    func createPlaylist(name: String, title: String, uri: String, service: String) {
        guard let socket = socket else { return }
        socket.emit(.createPlaylist, ["name": name])
        socket.once(.pushCreatePlaylist) {data, ack in
            self.addToPlaylist(name: name, uri: uri, service: service)
        }
    }
    
    func deletePlaylist(name: String) {
        guard let socket = socket else { return }
        socket.emit(.deletePlaylist, ["name": name])
        socket.once(.pushToastMessage) { data, ack in
            NotificationCenter.default.post(name: .playlistDeleted, object: name)
        }
    }
    
    func playPlaylist(name: String) {
        guard let socket = socket else { return }
        socket.emit(.playPlaylist, ["name": name])
        socket.once(.pushToastMessage) { data, ack in
            NotificationCenter.default.post(name: .playlistPlaying, object: name)
        }
    }
    
    // MARK: - manage plugins
    
    func getInstalledPlugins() {
        guard let socket = socket else { return }
        socket.emit(.getInstalledPlugins)
        socket.once(.pushInstalledPlugins) {data, ack in
            let json = JSON(data)
            if let items = json[0].arrayObject {
                self.installedPlugins = Mapper<PluginObject>().mapArray(JSONObject: items)
                NotificationCenter.default.post(name: .browsePlugins, object: self.installedPlugins)
            }
        }
    }
    
    func togglePlugin(name:String, category:String, action:String) {
        guard let socket = socket else { return }
        socket.emit(.pluginManager, ["name": name, "category": category, "action": action])
    }
    
    // MARK: - manage network
    
    func getInfoNetwork() {
        guard let socket = socket else { return }
        socket.emit(.getInfoNetwork)
        socket.once(.pushInfoNetwork) {data, ack in
            let json = JSON(data)
            if let items = json[0].arrayObject {
                self.connectedNetwork = Mapper<NetworkObject>().mapArray(JSONObject: items)
                NotificationCenter.default.post(name: .browseNetwork, object: self.connectedNetwork)
            }
        }
    }
    
    func getWirelessNetworks() {
        guard let socket = socket else { return }
        socket.emit(.getWirelessNetworks)
        socket.once(.pushWirelessNetworks) {data, ack in
            let json = JSON(data)
            if let items = json[0]["available"].arrayObject {
                self.wirelessNetwork = Mapper<NetworkObject>().mapArray(JSONObject: items)
                NotificationCenter.default.post(name: .browseWifi, object: self.wirelessNetwork)
            }
        }
    }

    // MARK: - manage system
    
    func shutdown() {
        guard let socket = socket else { return }
        socket.emit(.shutdown)
    }
    
    func reboot() {
        guard let socket = socket else { return }
        socket.emit(.reboot)
    }

}

// MARK: -

// Convenience extension to avoid code duplication

extension SocketIOClient {
    
    convenience init(for player: Player) {
        guard let url = URL(string: "http://\(player.host):\(player.port)") else {
            fatalError("Unable to construct valid url for player \(player)")
        }
        self.init(socketURL: url,  config: [.reconnectWait(5)])
    }
    
}
