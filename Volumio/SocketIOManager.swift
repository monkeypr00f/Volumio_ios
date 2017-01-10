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
        socket = SocketIOClient(socketURL: URL(string: "http://\(player).local:3000")!)
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
            NotificationCenter.default.post(name: NSNotification.Name("disconnected"), object: nil)
        })
        
        socket.on("reconnect") { data, ack in
            self.socketConnected = false
            NotificationCenter.default.post(name: NSNotification.Name("disconnected"), object: nil)
        }
        
        socket.on("connect") { data, ack in
            NotificationCenter.default.post(name: NSNotification.Name("connected"), object: nil)
            self.socketConnected = true
            self.getState()
        }
    }
    
    func reConnect() {
        let player = UserDefaults.standard.string(forKey: "selectedPlayer") ?? ""
        socket = SocketIOClient(socketURL: URL(string: "http://\(player).local:3000")!)
        self.establishConnection()
    }
    
    func changeServer(server:String) {        
        socket = SocketIOClient(socketURL: URL(string: "http://\(server).local:3000")!)
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
        socket.on("pushState") {data, ack in
            if let json = data[0] as? [String : Any] {
                self.currentTrack = Mapper<TrackObject>().map(JSONObject: json)
                NotificationCenter.default.post(name: NSNotification.Name("currentTrack"), object: self.currentTrack)
            }
        }
    }
    
    
    //manage sources
    
    func browseSources() {
        socket.emit("getBrowseSources")
        socket.once("pushBrowseSources") {data, ack in
            let json = JSON(data)
            if let sources = json[0].arrayObject {
                self.currentSources = Mapper<SourceObject>().mapArray(JSONObject: sources)
                NotificationCenter.default.post(name: NSNotification.Name("browseSources"), object: self.currentSources)
            }
        }
    }
    
    func browseLibrary(uri:String) {
        socket.emit("browseLibrary", ["uri":uri])
        socket.once("pushBrowseLibrary") {data, ack in
            let json = JSON(data)
            if let items = json[0]["navigation"]["lists"][0]["items"].arrayObject {
                self.currentLibrary = Mapper<LibraryObject>().mapArray(JSONObject: items)
                NotificationCenter.default.post(name: NSNotification.Name("browseLibrary"), object: self.currentLibrary)
            }
        }
    }
    
    func browseSearch(text:String) {
        socket.emit("search", ["type": "", "value": text])
        socket.once("pushBrowseLibrary") {data, ack in
            let json = JSON(data)
            if let items = json[0]["navigation"]["lists"].arrayObject {
                self.currentSearch = Mapper<SearchResultObject>().mapArray(JSONObject: items)
                NotificationCenter.default.post(name: NSNotification.Name("browseSearch"), object: self.currentSearch)
            }
        }
    }
    
    func addToQueue(uri:String, title:String, service:String) {
        socket.emit("addToQueue", ["uri":uri, "title":title, "service":service])
        socket.once("pushQueue") {data, ack in
            NotificationCenter.default.post(name: NSNotification.Name("addedToQueue"), object: title)
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
                NotificationCenter.default.post(name: NSNotification.Name("addedToQueue"), object: title)
            }
        }
    }
    
    
    //manage queue
    
    func getQueue() {
        socket.emit("getQueue")
        socket.once("pushQueue") {data, ack in
            if let json = data[0] as? [[String:Any]] {
                self.currentQueue = Mapper<TrackObject>().mapArray(JSONObject: json)
                NotificationCenter.default.post(name: NSNotification.Name("currentQueue"), object: self.currentQueue)
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
            NotificationCenter.default.post(name: NSNotification.Name("removedfromQueue"), object: nil)
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
                NotificationCenter.default.post(name: NSNotification.Name("listPlaylists"), object: self.currentPlaylists)
            }
        }
    }
    
    func addToPlaylist(name:String, uri:String, service:String) {
        socket.emit("addToPlaylist", ["name": name, "uri":uri, "service":service])
        socket.once("pushToastMessage") {data, ack in
            NotificationCenter.default.post(name: NSNotification.Name("addedToPlaylist"), object: name)
        }
    }
    
    func removeFromPlaylist(name:String, uri:String, service:String) {
        socket.emit("removeFromPlaylist", ["name": name, "uri":uri, "service":service])
        socket.once("pushToastMessage") {data, ack in
            NotificationCenter.default.post(name: NSNotification.Name("removedFromPlaylist"), object: name)
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
            print(data)
            NotificationCenter.default.post(name: NSNotification.Name("playlistPlaying"), object: name)
        }
    }
    
    func deletePlaylist(name:String) {
        socket.emit("deletePlaylist", ["name": name])
        socket.once("pushToastMessage") { data, ack in
            NotificationCenter.default.post(name: NSNotification.Name("playlistDeleted"), object: name)
        }
    }
    
    //manage plugins
    
    func getInstalledPlugins() {
        self.socket.emit("getInstalledPlugins")
        socket.once("pushInstalledPlugins") {data, ack in
            let json = JSON(data)
            if let items = json[0].arrayObject {
                self.installedPlugins = Mapper<PluginObject>().mapArray(JSONObject: items)
                NotificationCenter.default.post(name: NSNotification.Name("browsePlugins"), object: self.installedPlugins)
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
                NotificationCenter.default.post(name: NSNotification.Name("browseNetwork"), object: self.connectedNetwork)
            }
        }
    }
    
    func getWirelessNetworks() {
        socket.emit("getWirelessNetworks")
        socket.once("pushWirelessNetworks") {data, ack in
            let json = JSON(data)
            if let items = json[0]["available"].arrayObject {
                self.wirelessNetwork = Mapper<NetworkObject>().mapArray(JSONObject: items)
                NotificationCenter.default.post(name: NSNotification.Name("browseWifi"), object: self.wirelessNetwork)
            }
        }
    }
    
    
    //debug
//    socket.onAny {
//      print("Got event: \($0.event), with items: \($0.items)")
//    }
    
}

