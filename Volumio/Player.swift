//
//  Player.swift
//  Volumio
//
//  Created by Michael Baumgärtner on 19.01.17.
//  Copyright © 2017 Federico Sintucci. All rights reserved.
//

import Foundation

/**
 This represents a Volumio player. It is defined by its name, host and port.
*/
struct Player {
    var name: String
    var host: String
    var port: Int

    /// Returns the player’s url for web ui
    var url: URL? {
        return URL(string: "http://\(host)")
    }

    /// Validates this player’s properties
    var isValid: Bool {
        return validate(name: name) && validate(host: host) && validate(port: port)
    }
    
    private func validate(name: String) -> Bool {
        return name.characters.count > 0
    }
    
    private func validate(host: String) -> Bool {
        // ip v6 addr
        var sin6 = sockaddr_in6()
        if host.withCString({ cstring in inet_pton(AF_INET6, cstring, &sin6.sin6_addr) }) == 1 {
            return true
        }
        // ip v4 addr
        var sin = sockaddr_in()
        if host.withCString({ cstring in inet_pton(AF_INET, cstring, &sin.sin_addr) }) == 1 {
            return true
        }
        return false
    }
    
    private func validate(port: Int) -> Bool {
        return port > 0 && port < 65536
    }
}

extension SafeUserDefaults {
    
    subscript(key: DefaultsKey<Player?>) -> Player? {
        get {
            guard let dict = self[key.key].dictionary,
                  let name = dict["name"] as? String,
                  let host = dict["host"] as? String,
                  let port = dict["port"] as? Int
                else { return nil }
            return Player(name: name, host: host, port: port)
        }
        set {
            if let player = newValue {
                let dict = [
                    "name": player.name,
                    "host": player.host,
                    "port": player.port
                ] as [String : Any]
                set(key, dict)
            }
            else {
                set(key, nil)
            }
        }
    }
    
}
