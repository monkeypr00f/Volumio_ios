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
    var currentSources : [[String:Any]]?
    var currentLibrary : [LibraryObject]?
    
    func establishConnection() {
        socket.connect()
        socket.on("connect") { data, ack in
            self.socket.emit("getState")
        }
    }
    
    func closeConnection() {
        socket.disconnect()
    }
    
    func doAction(action:String) {
        socket.emit(action)
    }
    
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
            NotificationCenter.default.post(name: NSNotification.Name("currentTrack"), object: self.currentTrack)
        }
    }
    
    func browseSources() {
        self.socket.emit("getBrowseSources")
        socket.on("pushBrowseSources") {data, ack in
            if let json = data[0] as? [[String : Any]] {
                self.currentSources = json
            }
            NotificationCenter.default.post(name: NSNotification.Name("browseSources"), object: self.currentSources)
        }
    }
    
    func browseLibrary(uri:String) {
        socket.emit("browseLibrary", ["uri":uri])
        socket.on("pushBrowseLibrary") {data, ack in
            if let json = data as? [[String: Any]],
            let navigation = json.first?["navigation"] as? [String:Any],
                let list = navigation["list"] as? [[String: Any]]  {
                self.currentLibrary = Mapper<LibraryObject>().mapArray(JSONObject: list)
            }
            NotificationCenter.default.post(name: NSNotification.Name("browseLibrary"), object: self.currentLibrary)
        }
    }
    
    func getQueue() {
        self.socket.emit("getQueue")
        socket.on("pushQueue") {data, ack in
            if let json = data[0] as? [[String:Any]] {
                self.currentPlaylist = Mapper<TrackObject>().mapArray(JSONObject: json)
            }
            NotificationCenter.default.post(name: NSNotification.Name("currentPlaylist"), object: nil)
        }
    }
    
    func removeFromQueue(position:Int) {
        self.socket.emit("removeFromQueue", position)
        self.getQueue()
    }
    
//    socket.onAny {
//    print("Got event: \($0.event), with items: \($0.items)")
//    }
    
}

