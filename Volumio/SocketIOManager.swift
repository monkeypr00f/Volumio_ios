//
//  SocketIOManager.swift
//  Volumio
//
//  Created by Federico Sintucci on 21/09/16.
//  Copyright © 2016 Federico Sintucci. All rights reserved.

import UIKit
import SocketIO
import ObjectMapper
import SwiftyJSON

class SocketIOManager: NSObject {
    
    static let sharedInstance = SocketIOManager()
    var socket: SocketIOClient!
    
    override init() {
        let player = UserDefaults.standard.string(forKey: "selectedPlayer") ?? ""
        socket = SocketIOClient(for: player)
        socket.reconnectWait = 5
    }
    
    var currentTrack : TrackObject?
    var currentQueue : [TrackObject]?
    var currentSources : [SourceObject]?
    var currentLibrary : [LibraryObject]?
    var currentSearch : [SearchResultObject]?
    var currentPlaylists : [Any]?
    var installedPlugins : [PluginObject]?
    var connectedNetwork : [NetworkObject]?
    var wirelessNetwork : [NetworkObject]?
    
    var socketConnected : Bool = false
    
    // manage connection
    
    func establishConnection() {
        
        socket.connect(timeoutAfter: 10, withHandler: { data in
            self.socketConnected = false
            NotificationCenter.default.post(name: .disconnected, object: nil)
        })
        
        socket.on("reconnect") { data, ack in
            self.socketConnected = false
            NotificationCenter.default.post(name: .disconnected, object: nil)
        }
        
        socket.on("connect") { data, ack in
            NotificationCenter.default.post(name: .connected, object: nil)
            self.socketConnected = true
            self.getState()
        }
		
		socket.on("pushState") {data, ack in
			if let json = data[0] as? [String : Any] {
				self.currentTrack = Mapper<TrackObject>().map(JSONObject: json)
				NotificationCenter.default.post(name: NSNotification.Name("currentTrack"), object: self.currentTrack)
			}
		}
    }
	
    func reConnect() {
        let player = UserDefaults.standard.string(forKey: "selectedPlayer") ?? ""
        socket = SocketIOClient(for: player)
        self.establishConnection()
    }
    
    func changeServer(server:String) {        
        socket = SocketIOClient(for: server)
        self.establishConnection()
    }
    
    func closeConnection() {
        socketConnected = false
        socket.disconnect()
    }
    
    
    //common
    
    func doAction(action:String) {
        socket.emit(action)
    }
    
    func sendMethod(endpoint:String, method:String, data:[String:Any]) {
        socket.emit("callMethod", ["endpoint": endpoint, "method": method, "data": data])
    }
    
    
    //manage playback
    
    func playTrack(position:Int) {
        socket.emit("play", ["value": position])
        self.getState()
    }
    
    func setVolume(value:Int) {
        socket.emit("volume", value)
    }
    
    func getState() {
        self.socket.emit("getState")
    }
    
    
    //manage sources
    
    func browseSources() {
        socket.emit("getBrowseSources")
        socket.once("pushBrowseSources") {data, ack in
            let json = JSON(data)
            if let sources = json[0].arrayObject {
                self.currentSources = Mapper<SourceObject>().mapArray(JSONObject: sources)
                NotificationCenter.default.post(name: .browseSources, object: self.currentSources)
            }
        }
    }
    
    func browseLibrary(uri:String) {
        socket.emit("browseLibrary", ["uri":uri])
        socket.once("pushBrowseLibrary") {data, ack in
            let json = JSON(data)
            if let items = json[0]["navigation"]["lists"][0]["items"].arrayObject {
                self.currentLibrary = Mapper<LibraryObject>().mapArray(JSONObject: items)
                NotificationCenter.default.post(name: .browseLibrary, object: self.currentLibrary)
            }
        }
    }
    
    func browseSearch(text:String) {
        socket.emit("search", ["type": "", "value": text])
        socket.once("pushBrowseLibrary") {data, ack in
            let json = JSON(data)
            if let items = json[0]["navigation"]["lists"].arrayObject {
                self.currentSearch = Mapper<SearchResultObject>().mapArray(JSONObject: items)
                NotificationCenter.default.post(name: .browseSearch, object: self.currentSearch)
            }
        }
    }
    
    func addToQueue(uri:String, title:String, service:String) {
        socket.emit("addToQueue", ["uri":uri, "title":title, "service":service])
        socket.once("pushQueue") {data, ack in
            NotificationCenter.default.post(name: .addedToQueue, object: title)
        }
    }
    
    func clearAndPlay(uri:String, title:String, service:String) {
        socket.emit("clearQueue")
        socket.once("pushQueue") {data, ack in
            if let json = data[0] as? [[String:Any]] {
                if json.count == 0 {
                    self.socket.emit("addToQueue", ["uri":uri, "title":title, "service":service])
                    self.socket.once("pushQueue") {data, ack in
                        self.playTrack(position: 0)
                    }
                }
            }
        }
    }
    
    func addAndPlay(uri:String, title:String, service:String) {
        self.getQueue()
        socket.once("pushQueue") {data, ack in
            if let queryItems = self.currentQueue?.count {
                self.socket.emit("addToQueue", ["uri":uri, "title":title, "service":service])
                self.socket.once("pushQueue") {data, ack in
                    self.playTrack(position: queryItems)
                }
                NotificationCenter.default.post(name: .addedToQueue, object: title)
            }
        }
    }
    
    
    //manage queue
    
    func getQueue() {
        socket.emit("getQueue")
        socket.once("pushQueue") {data, ack in
            if let json = data[0] as? [[String:Any]] {
                self.currentQueue = Mapper<TrackObject>().mapArray(JSONObject: json)
                NotificationCenter.default.post(name: .currentQueue, object: self.currentQueue)
            }
        }
    }
    
    func sortQueue(from:Int, to:Int) {
        socket.emit("moveQueue", ["from":"\(from)", "to":"\(to)"])
        self.getQueue()
    }
    
    func removeFromQueue(position:Int) {
        socket.emit("removeFromQueue", ["value":"\(position)"])
        socket.once("pushToastMessage") { data, ack in
            NotificationCenter.default.post(name: .removedfromQueue, object: nil)
        }
    }
    
    func toggleRepeat(value:Int) {
        socket.emit("setRepeat", ["value": value])
    }
    
    func toggleRandom(value:Int) {
        socket.emit("setRandom", ["value": value])
    }
    
    func toggleConsume(value:Int) {
        socket.emit("setConsume", ["value": value])
    }
    
    func clearQueue() {
        self.doAction(action: "stop")
        socket.emit("clearQueue")
        socket.once("pushQueue") {data, ack in
            self.getQueue()
        }
    }
    
    
    //manage playlists
    
    func listPlaylist() {
        self.socket.emit("listPlaylist")
        socket.once("pushListPlaylist") {data, ack in
            let json = JSON(data)
            if let items = json[0].arrayObject {
                self.currentPlaylists = items
                NotificationCenter.default.post(name: .listPlaylists, object: self.currentPlaylists)
            }
        }
    }
    
    func addToPlaylist(name:String, uri:String, service:String) {
        socket.emit("addToPlaylist", ["name": name, "uri":uri, "service":service])
        socket.once("pushToastMessage") {data, ack in
            NotificationCenter.default.post(name: .addedToPlaylist, object: name)
        }
    }
    
    func removeFromPlaylist(name:String, uri:String, service:String) {
        socket.emit("removeFromPlaylist", ["name": name, "uri":uri, "service":service])
        socket.once("pushToastMessage") {data, ack in
            NotificationCenter.default.post(name: .removedFromPlaylist, object: name)
        }
    }
    
    func createPlaylist(name:String, title:String, uri:String, service:String) {
        socket.emit("createPlaylist", ["name": name])
        socket.once("pushCreatePlaylist") {data, ack in
            self.addToPlaylist(name: name, uri: uri, service: service)
        }
    }
    
    func playPlaylist(name:String) {
        socket.emit("playPlaylist", ["name": name])
        socket.once("pushToastMessage") { data, ack in
            NotificationCenter.default.post(name: .playlistPlaying, object: name)
        }
    }
    
    func deletePlaylist(name:String) {
        socket.emit("deletePlaylist", ["name": name])
        socket.once("pushToastMessage") { data, ack in
            NotificationCenter.default.post(name: .playlistDeleted, object: name)
        }
    }
    
    //manage plugins
    
    func getInstalledPlugins() {
        self.socket.emit("getInstalledPlugins")
        socket.once("pushInstalledPlugins") {data, ack in
            let json = JSON(data)
            if let items = json[0].arrayObject {
                self.installedPlugins = Mapper<PluginObject>().mapArray(JSONObject: items)
                NotificationCenter.default.post(name: .browsePlugins, object: self.installedPlugins)
            }
        }
    }
    
    func togglePlugin(name:String, category:String, action:String) {
        self.socket.emit("pluginManager", ["name": name, "category": category, "action": action])
    }
    
    //manage network
    
    func getInfoNetwork() {
        socket.emit("getInfoNetwork")
        socket.once("pushInfoNetwork") {data, ack in
            let json = JSON(data)
            if let items = json[0].arrayObject {
                self.connectedNetwork = Mapper<NetworkObject>().mapArray(JSONObject: items)
                NotificationCenter.default.post(name: .browseNetwork, object: self.connectedNetwork)
            }
        }
    }
    
    func getWirelessNetworks() {
        socket.emit("getWirelessNetworks")
        socket.once("pushWirelessNetworks") {data, ack in
            let json = JSON(data)
            if let items = json[0]["available"].arrayObject {
                self.wirelessNetwork = Mapper<NetworkObject>().mapArray(JSONObject: items)
                NotificationCenter.default.post(name: .browseWifi, object: self.wirelessNetwork)
            }
        }
    }
    
    
    //debug
//    socket.onAny {
//      print("Got event: \($0.event), with items: \($0.items)")
//    }
    
}

// Notifications posted by this module

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

// Convenience extension to avoid code duplication

extension SocketIOClient {
    
    convenience init(for player: String) {
        guard let url = URL(string: "http://\(player).local:3000") else {
            fatalError("Unable to construct valid url for player \(player)")
        }
        self.init(socketURL: url)
    }
    
}
