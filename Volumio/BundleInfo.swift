//
//  BundleInfo.swift
//
//  Created by Michael Baumgärtner on 25.11.16.
//  Copyright © 2016 Michael Baumgärtner. All rights reserved.
//

import Foundation

/// Statically-typed Bundle info dictionary
public struct SafeBundleInfo {
    
    fileprivate let bundle: Bundle
    
    fileprivate init(_ bundle: Bundle) {
        self.bundle = bundle
    }
    
    public class Proxy {
        fileprivate let info: [String:Any]
        fileprivate let key: String
        
        fileprivate init(_ info: [String:Any], _ key: String) {
            self.info = info
            self.key = key
        }
        
        public var string: String? {
            return info[key] as? String
        }
        
        public var int: Int? {
            return info[key] as? Int
        }
    }
    
    public subscript(key: String) -> Proxy? {
        guard let info = bundle.infoDictionary else { return nil }
        return Proxy(info, key)
    }
    
    public subscript(key: String) -> Any? {
        let proxy: Proxy? = self[key]
        return proxy
    }
    
    public func has(key: String) -> Bool {
        guard let info = bundle.infoDictionary else { return false }
        return info[key] != nil
    }
}

// global bundle info

public let BundleInfo = SafeBundleInfo(Bundle.main)

// keys

public class InfoKeys {
    fileprivate init() {}
}

// generic key

public class InfoKey<ValueType>: InfoKeys {
    
    public let key: String
    
    public init(_ key: String) {
        self.key = key
        super.init()
    }
    
    public convenience init(_ uuid: UUID) {
        self.init(uuid.uuidString)
    }
    
}

// generic functions

extension SafeBundleInfo {
    
    public func has<T>(key: InfoKey<T>) -> Bool {
        guard let info = bundle.infoDictionary else { return false }
        return info[key.key] != nil
    }
    
}

// typed subscripts

extension SafeBundleInfo {
    
    public subscript(key: InfoKey<String?>) -> String? {
        return self[key.key]?.string
    }
    
    public subscript(key: InfoKey<String>) -> String {
        return self[key.key]?.string ?? ""
    }
    
    public subscript(key: InfoKey<Int?>) -> Int? {
        return self[key.key]?.int
    }
    
    public subscript(key: InfoKey<Int>) -> Int {
        return self[key.key]?.int ?? 0
    }
    
}

// defined keys

extension InfoKeys {
    static let bundleIdentifier = InfoKey<String?>("CFBundleIdentifier")
    static let bundleName = InfoKey<String?>("CFBundleName")
    static let bundleVersion = InfoKey<String?>("CFBundleVersion")
}
