//
//  UserDefaults.swift
//
//  Created by Michael Baumgärtner on 25.11.16.
//  Based on https://github.com/radex/SwiftyUserDefaults.
//

import Foundation

/// Statically-typed UserDefaults
public struct SafeUserDefaults {
	
	fileprivate let defaults: UserDefaults
	
	fileprivate init(_ defaults: UserDefaults) {
		self.defaults = defaults
	}

	public class Proxy {
		fileprivate let defaults: UserDefaults
		fileprivate let key: String
		
		fileprivate init(_ defaults: UserDefaults, _ key: String) {
			self.defaults = defaults
			self.key = key
		}
		
		public var object: Any? {
			return defaults.object(forKey: key)
		}
		
		public var string: String? {
			return defaults.string(forKey: key)
		}
		
		public var array: [Any]? {
			return defaults.array(forKey: key)
		}
		
		public var dictionary: [String: Any]? {
			return defaults.dictionary(forKey: key)
		}
		
		public var data: Data? {
			return defaults.data(forKey: key)
		}
		
		public var date: Date? {
			return object as? Date
		}
		
		public var number: NSNumber? {
			return defaults.numberForKey(key)
		}
		
        public var double: Double? {
            return number?.doubleValue
        }
        
		public var int: Int? {
			return number?.intValue
		}
		
		public var bool: Bool? {
			return number?.boolValue
		}
		
		public var stringValue: String {
			return string ?? ""
		}
		
		public var arrayValue: [Any] {
			return array ?? []
		}
		
		public var dictionaryValue: [String: Any] {
			return dictionary ?? [:]
		}
		
		public var dataValue: Data {
			return data ?? Data()
		}
		
		public var numberValue: NSNumber {
			return number ?? 0
		}
		
		public var intValue: Int {
			return int ?? 0
		}
		
		public var doubleValue: Double {
			return double ?? 0
		}
		
		public var boolValue: Bool {
			return bool ?? false
		}
	}
	
	public subscript(key: String) -> Proxy {
		return Proxy(defaults, key)
	}
	
	public subscript(key: String) -> Any? {
		get {
			let proxy: Proxy = self[key]
			return proxy
		}
		set {
			if let value = newValue {
				switch value {
				case let v as Double:
                    defaults.set(v, forKey: key)
				case let v as Int:
                    defaults.set(v, forKey: key)
				case let v as Bool:
                    defaults.set(v, forKey: key)
				case let v as URL:
                    defaults.set(v, forKey: key)
				default:
                    defaults.set(value, forKey: key)
				}
			}
			else {
				defaults.removeObject(forKey: key)
			}
		}
	}
	
	public func has(key: String) -> Bool {
		return defaults.object(forKey: key) != nil
	}

	public func remove(for key: String) {
		defaults.removeObject(forKey: key)
	}
	
	public func removeAll() {
		for key in defaults.dictionaryRepresentation().keys {
			defaults.removeObject(forKey: key)
		}
	}
	
	public var count: Int {
		return defaults.dictionaryRepresentation().count
	}

}

// global user defaults

public var Defaults = SafeUserDefaults(UserDefaults.standard)

// keys

public class DefaultsKeys {
	fileprivate init() {}
}

// generic key

public class DefaultsKey<ValueType>: DefaultsKeys {

	public let key: String
	
	public init(_ key: String) {
		self.key = key
		super.init()
	}

    public convenience init(_ uuid: UUID) {
        self.init(uuid.uuidString)
    }

}

// generic setter

extension SafeUserDefaults {
	
	public mutating func set<T>(_ key: DefaultsKey<T>, _ value: Any?) {
		self[key.key] = value
	}
	
}

// generic functions

extension SafeUserDefaults {
	
	public func has<T>(key: DefaultsKey<T>) -> Bool {
		return defaults.object(forKey: key.key) != nil
	}
	
	public func remove<T>(_ key: DefaultsKey<T>) {
		defaults.removeObject(forKey: key.key)
	}
	
}

// typed subscripts

extension SafeUserDefaults {
	
	public subscript(key: DefaultsKey<String?>) -> String? {
		get { return defaults.string(forKey: key.key) }
		set { set(key, newValue) }
	}
	
	public subscript(key: DefaultsKey<String>) -> String {
		get { return defaults.string(forKey: key.key) ?? "" }
		set { set(key, newValue) }
	}
	
	public subscript(key: DefaultsKey<Int?>) -> Int? {
		get { return defaults.numberForKey(key.key)?.intValue }
		set { set(key, newValue) }
	}
	
	public subscript(key: DefaultsKey<Int>) -> Int {
		get { return defaults.numberForKey(key.key)?.intValue ?? 0 }
		set { set(key, newValue) }
	}
	
	public subscript(key: DefaultsKey<Double?>) -> Double? {
		get { return defaults.numberForKey(key.key)?.doubleValue }
		set { set(key, newValue) }
	}
	
	public subscript(key: DefaultsKey<Double>) -> Double {
		get { return defaults.numberForKey(key.key)?.doubleValue ?? 0.0 }
		set { set(key, newValue) }
	}
	
	public subscript(key: DefaultsKey<Bool?>) -> Bool? {
		get { return defaults.numberForKey(key.key)?.boolValue }
		set { set(key, newValue) }
	}
	
	public subscript(key: DefaultsKey<Bool>) -> Bool {
		get { return defaults.numberForKey(key.key)?.boolValue ?? false }
		set { set(key, newValue) }
	}
	
	public subscript(key: DefaultsKey<Any?>) -> Any? {
		get { return defaults.object(forKey: key.key) }
		set { set(key, newValue) }
	}
	
	public subscript(key: DefaultsKey<Data?>) -> Data? {
		get { return defaults.data(forKey: key.key) }
		set { set(key, newValue) }
	}
	
	public subscript(key: DefaultsKey<Data>) -> Data {
		get { return defaults.data(forKey: key.key) ?? Data() }
		set { set(key, newValue) }
	}
	
	public subscript(key: DefaultsKey<Date?>) -> Date? {
		get { return defaults.object(forKey: key.key) as? Date }
		set { set(key, newValue) }
	}
	
	public subscript(key: DefaultsKey<URL?>) -> URL? {
		get { return defaults.url(forKey: key.key) }
		set { set(key, newValue) }
	}
	
	public subscript(key: DefaultsKey<[String: Any]?>) -> [String: Any]? {
		get { return defaults.dictionary(forKey: key.key) }
		set { set(key, newValue) }
	}
	
	public subscript(key: DefaultsKey<[String: Any]>) -> [String: Any] {
		get { return defaults.dictionary(forKey: key.key) ?? [:] }
		set { set(key, newValue) }
	}
	
}

// helpers

extension SafeUserDefaults {

	public mutating func archive<T: RawRepresentable>(_ key: DefaultsKey<T>, _ value: T) {
		set(key, value.rawValue)
	}
	
	public mutating func archive<T: RawRepresentable>(_ key: DefaultsKey<T?>, _ value: T?) {
		if let value = value {
			set(key, value.rawValue)
		}
		else {
			remove(key)
		}
	}
	
	public func unarchive<T: RawRepresentable>(_ key: DefaultsKey<T?>) -> T? {
		return defaults.object(forKey: key.key).flatMap { T(rawValue: $0 as! T.RawValue) }
	}
	
	public func unarchive<T: RawRepresentable>(_ key: DefaultsKey<T>) -> T? {
		return defaults.object(forKey: key.key).flatMap { T(rawValue: $0 as! T.RawValue) }
	}
	
}

extension SafeUserDefaults {
	
	public mutating func archive<T>(_ key: DefaultsKey<T>, _ value: T) {
		set(key, NSKeyedArchiver.archivedData(withRootObject: value))
	}
	
	public mutating func archive<T>(_ key: DefaultsKey<T?>, _ value: T?) {
		if let value = value {
			set(key, NSKeyedArchiver.archivedData(withRootObject: value))
		}
		else {
			remove(key)
		}
	}
	
	public func unarchive<T>(_ key: DefaultsKey<T>) -> T? {
		return defaults.data(forKey: key.key).flatMap { NSKeyedUnarchiver.unarchiveObject(with: $0) } as? T
	}
	
	public func unarchive<T>(_ key: DefaultsKey<T?>) -> T? {
		return defaults.data(forKey: key.key).flatMap { NSKeyedUnarchiver.unarchiveObject(with: $0) } as? T
	}
	
}

// MARK: -

extension UserDefaults {
	
	func numberForKey(_ key: String) -> NSNumber? {
		return object(forKey: key) as? NSNumber
	}
	
}
