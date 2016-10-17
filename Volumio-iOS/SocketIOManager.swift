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
    
    override init() {
        super.init()
    }
    
    var socket: SocketIOClient = SocketIOClient(socketURL: URL(string: "http://volumio.local:3000")!)
    
    var currentTrack : TrackObject?
    var currentPlaylist : [TrackObject]?
    var currentSources : [SourceObject]?
    var currentLibrary : [LibraryObject]?
    var installedPlugins : [PluginObject]?
    
    
    // manage connection
    
    func establishConnection() {
        socket.connect()
        socket.on("connect") { data, ack in
            self.socket.emit("getState")
            NotificationCenter.default.post(name: NSNotification.Name("connected"), object: nil)
        }
        socket.on("reconnect") { data, ack in
            NotificationCenter.default.post(name: NSNotification.Name("disconnected"), object: nil)
        }
    }
    
    func closeConnection() {
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
        socket.emit("play", ["value":"\(position)"])
    }
    
    func setVolume(value:Int) {
        socket.emit("volume", value)
    }
    
    func getState() {
        socket.on("pushState") {data, ack in
            if let json = data[0] as? [String : Any] {
                self.currentTrack = Mapper<TrackObject>().map(JSONObject: json)
            }
            NotificationCenter.default.post(name: NSNotification.Name("currentTrack"), object: nil)
        }
    }
    
    //manage sources
    
    func browseSources() {
        socket.emit("getBrowseSources")
        socket.on("pushBrowseSources") {data, ack in
            let json = JSON(data)
            if let sources = json[0].arrayObject {
                self.currentSources = Mapper<SourceObject>().mapArray(JSONObject: sources)
            }
            NotificationCenter.default.post(name: NSNotification.Name("browseSources"), object: nil)
        }
    }
    
    func browseLibrary(uri:String) {
        socket.emit("browseLibrary", ["uri":uri])
        socket.on("pushBrowseLibrary") {data, ack in
            let json = JSON(data)
            if let items = json[0]["navigation"]["lists"][0]["items"].arrayObject {
                self.currentLibrary = Mapper<LibraryObject>().mapArray(JSONObject: items)
            }
            NotificationCenter.default.post(name: NSNotification.Name("browseLibrary"), object: nil)
        }
    }
    
    //manage queue
    
    func getQueue() {
        socket.emit("getQueue")
        socket.on("pushQueue") {data, ack in
            if let json = data[0] as? [[String:Any]] {
                self.currentPlaylist = Mapper<TrackObject>().mapArray(JSONObject: json)
            }
            NotificationCenter.default.post(name: NSNotification.Name("currentPlaylist"), object: nil)
        }
    }
    
    func addToQueue(uri:String, title:String, service:String) {
        socket.emit("addToQueue", ["uri":uri, "title":title, "service":service])
    }
    
    func clearAndPlay(uri:String, title:String, service:String) {
        socket.emit("clearQueue")
        socket.on("pushQueue") {data, ack in
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
            socket.on("pushQueue") {data, ack in
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
        socket.emit("setRepeat", ["value": "\(value)"])
    }
    
    func toggleRandom(value:Int) {
        socket.emit("setRandom", ["value": "\(value)"])
    }
    
    //manage plugins
    
    func getInstalledPlugins() {
        self.socket.emit("getInstalledPlugins")
        socket.on("pushInstalledPlugins") {data, ack in
            let json = JSON(data)
            if let items = json[0].arrayObject {
                self.installedPlugins = Mapper<PluginObject>().mapArray(JSONObject: items)
            }
            NotificationCenter.default.post(name: NSNotification.Name("browsePlugins"), object: nil)
        }
    }
    
    func togglePlugin(name:String, category:String, action:String) {
        self.socket.emit("pluginManager", ["name": name, "category": category, "action": action])
    }
    
    //debug
//    socket.onAny {
//      print("Got event: \($0.event), with items: \($0.items)")
//    }
    
}

