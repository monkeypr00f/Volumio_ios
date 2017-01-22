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
    
    var socket: SocketIOClient!
    
    override init() {
        let player = UserDefaults.standard.string(forKey: "selectedPlayer") ?? ""
        socket = SocketIOClient(for: player)
        socket.reconnectWait = 5
    }
    
    var currentTrack: TrackObject?
    var currentQueue: [TrackObject]?
    var currentSources : [SourceObject]?
    var currentLibrary: [LibraryObject]?
    var currentSearch: [SearchResultObject]?
    var currentPlaylists: [Any]?
    var installedPlugins: [PluginObject]?
    var connectedNetwork: [NetworkObject]?
    var wirelessNetwork: [NetworkObject]?
    
    var socketConnected: Bool = false
    
    // MARK: - manage connection
    
    /**
        Establishes a connection to the player.
    */
    func establishConnection() {

        socket.connect(timeoutAfter: 10) {
            self.socketConnected = false
            NotificationCenter.default.post(name: .disconnected, object: nil)
        }
        
        socket.on(.connect) { data, ack in
            self.socketConnected = true
            NotificationCenter.default.post(name: .connected, object: nil)

            self.getState()
        }
        
        socket.on(.reconnect) { data, ack in
            self.socketConnected = false
            NotificationCenter.default.post(name: .disconnected, object: nil)
        }
        
        socket.on(.pushState) { data, ack in
            guard let json = data[0] as? [String: Any] else { return }
            
            self.currentTrack = Mapper<TrackObject>().map(JSONObject: json)
            NotificationCenter.default.post(name: .currentTrack, object: self.currentTrack)
        }
    }
	
    /**
        Connects to the player with the specified name.
     
        - parameter player: Name for the player to connect to.
        - parameter setDefault: If `true`, stores the specified player as default. Defaults to `false`.
    */
    func connect(to player: String, setDefault: Bool = false) {
        if setDefault {
            UserDefaults.standard.set(player, forKey: "selectedPlayer")
        }
        socket = SocketIOClient(for: player)
        socket.reconnectWait = 5
        establishConnection()
    }
    
    /**
        Reconnects to the default player.
    */
    func reconnect() {
        let player = UserDefaults.standard.string(forKey: "selectedPlayer") ?? ""
        connect(to: player)
    }
    
    /**
        Closes the connection to the player.
    */
    func closeConnection() {
        socketConnected = false
        socket.disconnect()
    }
    
    // MARK: - manage playback
    
    func play() {
        socket.emit(.play)
    }

    func stop() {
        socket.emit(.stop)
    }
    
    func pause() {
        socket.emit(.pause)
    }
    
    func playPrevious() {
        socket.emit(.prev)
    }
    
    func playNext() {
        socket.emit(.next)
    }
    
    func playTrack(position: Int) {
        socket.emit(.play, ["value": position])
        getState()
    }
    
    func setVolume(value: Int) {
        socket.emit(.volume, value)
    }
    
    func getState() {
        socket.emit(.getState)
    }
    
    // MARK: - manage sources
    
    func browseSources() {
        socket.emit(.getBrowseSources)
        socket.once(.pushBrowseSources) {data, ack in
            let json = JSON(data)
            if let sources = json[0].arrayObject {
                self.currentSources = Mapper<SourceObject>().mapArray(JSONObject: sources)
                NotificationCenter.default.post(name: .browseSources, object: self.currentSources)
            }
        }
    }
    
    func browseLibrary(uri: String) {
        socket.emit(.browseLibrary, ["uri":uri])
        socket.once(.pushBrowseLibrary) {data, ack in
            let json = JSON(data)
            if let items = json[0]["navigation"]["lists"][0]["items"].arrayObject {
                self.currentLibrary = Mapper<LibraryObject>().mapArray(JSONObject: items)
                NotificationCenter.default.post(name: .browseLibrary, object: self.currentLibrary)
            }
        }
    }
    
    func browseSearch(text: String) {
        socket.emit(.search, ["type": "", "value": text])
        socket.once(.pushBrowseLibrary) {data, ack in
            let json = JSON(data)
            if let items = json[0]["navigation"]["lists"].arrayObject {
                self.currentSearch = Mapper<SearchResultObject>().mapArray(JSONObject: items)
                NotificationCenter.default.post(name: .browseSearch, object: self.currentSearch)
            }
        }
    }
    
    func addToQueue(uri: String, title: String, service: String) {
        socket.emit(.addToQueue, ["uri":uri, "title":title, "service":service])
        socket.once(.pushQueue) {data, ack in
            NotificationCenter.default.post(name: .addedToQueue, object: title)
        }
    }
    
    func clearAndPlay(uri: String, title: String, service: String) {
        socket.emit(.clearQueue)
        socket.once(.pushQueue) {data, ack in
            if let json = data[0] as? [[String:Any]] {
                if json.count == 0 {
                    self.socket.emit(.addToQueue, ["uri":uri, "title":title, "service":service])
                    self.socket.once(.pushQueue) {data, ack in
                        self.playTrack(position: 0)
                    }
                }
            }
        }
    }
    
    func addAndPlay(uri: String, title: String, service: String) {
        getQueue()
        socket.once(.pushQueue) {data, ack in
            if let queryItems = self.currentQueue?.count {
                self.socket.emit(.addToQueue, ["uri":uri, "title":title, "service":service])
                self.socket.once(.pushQueue) {data, ack in
                    self.playTrack(position: queryItems)
                }
                NotificationCenter.default.post(name: .addedToQueue, object: title)
            }
        }
    }
    
    
    // MARK: - manage queue
    
    func getQueue() {
        socket.emit(.getQueue)
        socket.once(.pushQueue) {data, ack in
            if let json = data[0] as? [[String:Any]] {
                self.currentQueue = Mapper<TrackObject>().mapArray(JSONObject: json)
                NotificationCenter.default.post(name: .currentQueue, object: self.currentQueue)
            }
        }
    }
    
    func sortQueue(from: Int, to: Int) {
        socket.emit(.moveQueue, ["from":"\(from)", "to":"\(to)"])
        getQueue()
    }
    
    func removeFromQueue(position: Int) {
        socket.emit(.removeFromQueue, ["value":"\(position)"])
        socket.once(.pushToastMessage) { data, ack in
            NotificationCenter.default.post(name: .removedfromQueue, object: nil)
        }
    }
    
    func toggleRepeat(value: Int) {
        socket.emit(.setRepeat, ["value": value])
    }
    
    func toggleRandom(value: Int) {
        socket.emit(.setRandom, ["value": value])
    }
    
    func toggleConsume(value: Int) {
        socket.emit(.setConsume, ["value": value])
    }
    
    func clearQueue() {
        stop()
        socket.emit(.clearQueue)
        socket.once(.pushQueue) {data, ack in
            self.getQueue()
        }
    }
    
    // MARK: - manage playlists
    
    func listPlaylist() {
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
        socket.emit(.addToPlaylist, ["name": name, "uri":uri, "service":service])
        socket.once(.pushToastMessage) {data, ack in
            NotificationCenter.default.post(name: .addedToPlaylist, object: name)
        }
    }
    
    func removeFromPlaylist(name: String, uri: String, service: String) {
        socket.emit(.removeFromPlaylist, ["name": name, "uri":uri, "service":service])
        socket.once(.pushToastMessage) {data, ack in
            NotificationCenter.default.post(name: .removedFromPlaylist, object: name)
        }
    }
    
    func createPlaylist(name: String, title: String, uri: String, service: String) {
        socket.emit(.createPlaylist, ["name": name])
        socket.once(.pushCreatePlaylist) {data, ack in
            self.addToPlaylist(name: name, uri: uri, service: service)
        }
    }
    
    func deletePlaylist(name: String) {
        socket.emit(.deletePlaylist, ["name": name])
        socket.once(.pushToastMessage) { data, ack in
            NotificationCenter.default.post(name: .playlistDeleted, object: name)
        }
    }
    
    func playPlaylist(name: String) {
        socket.emit(.playPlaylist, ["name": name])
        socket.once(.pushToastMessage) { data, ack in
            NotificationCenter.default.post(name: .playlistPlaying, object: name)
        }
    }
    
    // MARK: - manage plugins
    
    func getInstalledPlugins() {
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
        socket.emit(.pluginManager, ["name": name, "category": category, "action": action])
    }
    
    // MARK: - manage network
    
    func getInfoNetwork() {
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
        socket.emit(.shutdown)
    }
    
    func reboot() {
        socket.emit(.reboot)
    }

}

// MARK: -

// Convenience extension to avoid code duplication

extension SocketIOClient {
    
    convenience init(for player: String) {
        guard let url = URL(string: "http://\(player).local:3000") else {
            fatalError("Unable to construct valid url for player \(player)")
        }
        self.init(socketURL: url)
    }
    
}
