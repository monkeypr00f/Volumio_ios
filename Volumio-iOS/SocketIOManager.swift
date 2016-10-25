//
//  SocketIOManager.swift
//  Volumio-iOS
//
//  Created by Federico Sintucci on 21/09/16.
//  Copyright © 2016 Federico Sintucci. All rights reserved.
//

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
    var currentPlaylist : [TrackObject]?
    var currentSources : [SourceObject]?
    var currentLibrary : [LibraryObject]?
    var currentSearch : [SearchResultObject]?
    var installedPlugins : [PluginObject]?
    var connectedNetwork : [NetworkObject]?
    var wirelessNetwork : [NetworkObject]?
    
    var socketConnected : Bool = false
    
    // manage connection
    
    func establishConnection() {
        
        socket.connect(timeoutAfter: 3, withHandler: { data in
            self.socketConnected = false
            NotificationCenter.default.post(name: NSNotification.Name("disconnected"), object: nil)
        })
        
        socket.once("reconnect") { data, ack in
            self.socketConnected = false
            NotificationCenter.default.post(name: NSNotification.Name("disconnected"), object: nil)
        }
        
        socket.once("connect") { data, ack in
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
    }
    
    func setVolume(value:Int) {
        socket.emit("volume", value)
    }
    
    func getState() {
        self.socket.emit("getState")
        socket.on("pushState") {data, ack in
            if let json = data[0] as? [String : Any] {
                self.currentTrack = Mapper<TrackObject>().map(JSONObject: json)
                NotificationCenter.default.post(name: NSNotification.Name("currentTrack"), object: nil)
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
                NotificationCenter.default.post(name: NSNotification.Name("browseSources"), object: nil)
            }
        }
    }
    
    func browseLibrary(uri:String) {
        socket.emit("browseLibrary", ["uri":uri])
        socket.once("pushBrowseLibrary") {data, ack in
            let json = JSON(data)
            if let items = json[0]["navigation"]["lists"][0]["items"].arrayObject {
                self.currentLibrary = Mapper<LibraryObject>().mapArray(JSONObject: items)
                NotificationCenter.default.post(name: NSNotification.Name("browseLibrary"), object: nil)
            }
        }
    }
    
    func browseSearch(text:String) {
        socket.emit("search", ["type": "", "value": text])
        socket.once("pushBrowseLibrary") {data, ack in
            let json = JSON(data)
            if let items = json[0]["navigation"]["lists"].arrayObject {
                self.currentSearch = Mapper<SearchResultObject>().mapArray(JSONObject: items)
                NotificationCenter.default.post(name: NSNotification.Name("browseSearch"), object: nil)
            }
        }
    }
    
    
    //manage queue
    
    func getQueue() {
        socket.emit("getQueue")
        socket.on("pushQueue") {data, ack in
            if let json = data[0] as? [[String:Any]] {
                self.currentPlaylist = Mapper<TrackObject>().mapArray(JSONObject: json)
                NotificationCenter.default.post(name: NSNotification.Name("currentQueue"), object: nil)
            }
        }
    }
    
    func addToQueue(uri:String, title:String, service:String) {
        socket.emit("addToQueue", ["uri":uri, "title":title, "service":service])
    }
    
    func clearAndPlay(uri:String, title:String, service:String) {
        socket.emit("clearQueue")
        socket.once("pushQueue") {data, ack in
            if let json = data[0] as? [[String:Any]] {
                if json.count == 0 {
                    self.socket.emit("addToQueue", ["uri":uri, "title":title, "service":service])
                } else {
                    self.playTrack(position: 0)
                }
            }
        }
    }
    
    func addAndPlay(uri:String, title:String, service:String) {
        if let lastPosition = currentPlaylist?.count {
            self.socket.emit("addToQueue", ["uri":uri, "title":title, "service":service])
            socket.once("pushQueue") {data, ack in
                if (self.currentPlaylist?.count)! > lastPosition {
                    self.playTrack(position: lastPosition)
                }
            }
        }
    }
    
    func sortQueue(from:Int, to:Int) {
        socket.emit("moveQueue", ["from":"\(from)", "to":"\(to)"])
        self.getQueue()
    }
    
    func removeFromQueue(position:Int) {
        socket.emit("removeFromQueue", ["value":"\(position)"])
        self.getQueue()
    }
    
    func toggleRepeat(value:Int) {
        socket.emit("setRepeat", ["value": value])
    }
    
    func toggleRandom(value:Int) {
        socket.emit("setRandom", ["value": value])
    }
    
    
    //manage plugins
    
    func getInstalledPlugins() {
        self.socket.emit("getInstalledPlugins")
        socket.once("pushInstalledPlugins") {data, ack in
            let json = JSON(data)
            if let items = json[0].arrayObject {
                self.installedPlugins = Mapper<PluginObject>().mapArray(JSONObject: items)
                NotificationCenter.default.post(name: NSNotification.Name("browsePlugins"), object: nil)
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
                NotificationCenter.default.post(name: NSNotification.Name("browseNetwork"), object: nil)
            }
        }
    }
    
    func getWirelessNetworks() {
        socket.emit("getWirelessNetworks")
        socket.once("pushWirelessNetworks") {data, ack in
            let json = JSON(data)
            if let items = json[0]["available"].arrayObject {
                self.wirelessNetwork = Mapper<NetworkObject>().mapArray(JSONObject: items)
                NotificationCenter.default.post(name: NSNotification.Name("browseWifi"), object: nil)
            }
        }
    }
    
    
    //debug
//    socket.onAny {
//      print("Got event: \($0.event), with items: \($0.items)")
//    }
    
}

