//
//  Logging.swift
//
//  Created by Michael Baumgärtner on 15.08.16.
//  Copyright © 2016 Michael Baumgärtner. All rights reserved.
//

import Foundation

public var Log = Logger(name: "Logger")

// MARK: - Enumeration LogLevel

public enum LogLevel: Int, Comparable {
    case trace  = 100
    case debug  = 200
    case info   = 300
    case warn   = 400
    case error  = 500
    case always = 999
    
    var symbol: String? {
        switch self {
        case .trace:  return "📓" //"🔈"
        case .debug:  return "📘" //"🔉"
        case .info:   return "📗" //"🔊"
        case .warn:   return "📙" //"📢"
        case .error:  return "📕" //"🔔"
        case .always: return "📚"
        }
    }
    
}

public func <(a: LogLevel, b: LogLevel) -> Bool {
    return a.rawValue < b.rawValue
}

// MARK: - Class Logger

open class Logger {
    
    open let name: String
    
    open var level: LogLevel
    
    var enabled: Bool
    
    init(name: String, level: LogLevel = .info) {
        self.name = name
        self.level = level
        self.enabled = true
    }
    
    open func log<T>(
        level logLevel: LogLevel,
        message logMessage: @autoclosure () -> T,
        file: String? = #file,
        line: Int? = #line,
        function: String? = #function
    ) {
        if (enabled) && (logLevel >= level) {
            var f: String = "???"
            var l: String = "???"
            var fn: String = "???"
            if let file = file {
                let filepath = file as NSString
                let filename = filepath.lastPathComponent as NSString
                f = filename.deletingPathExtension
            }
            if let line = line {
                l = String(line)
            }
            if let function = function {
                fn = function
            }
            var levelString = String(describing: logLevel).uppercased()
            if let symbol = logLevel.symbol {
                levelString = symbol + levelString
            }
            let infoString = "[\(self.name)][\(f):\(fn):\(l)]"
            let messageString = "\(logMessage())"
            print(infoString, separator: " ")
            print(levelString, messageString, separator: " ")
        }
    }
    
    open func trace<T>(
        _ message: @autoclosure () -> T,
        file: String? = #file,
        line: Int? = #line,
        function: String? = #function
    ) {
        self.log(level: .trace, message: message, file: file, line: line, function: function)
    }
    
    open func debug<T>(
        _ message: @autoclosure () -> T,
        file: String? = #file,
        line: Int? = #line,
        function: String? = #function
    ) {
        self.log(level: .debug, message: message, file: file, line: line, function: function)
    }
    
    open func info<T>(
        _ message: @autoclosure () -> T,
        file: String? = #file,
        line: Int? = #line,
        function: String? = #function
    ) {
        self.log(level: .info, message: message, file: file, line: line, function: function)
    }
    
    open func warn<T>(
        _ message: @autoclosure () -> T,
        file: String? = #file,
        line: Int? = #line,
        function: String? = #function
    ) {
        self.log(level: .warn, message: message, file: file, line: line, function: function)
    }
    
    open func error<T>(
        _ message: @autoclosure () -> T,
        file: String? = #file,
        line: Int? = #line,
        function: String? = #function
    ) {
        self.log(level: .error, message: message, file: file, line: line, function: function)
    }
    
    open func always<T>(
        _ message: @autoclosure () -> T,
        file: String? = #file,
        line: Int? = #line,
        function: String? = #function
    ) {
        self.log(level: .always, message: message, file: file, line: line, function: function)
    }
    
    open func log(_ level: LogLevel,
        file: String? = #file,
        line: Int? = #line,
        function: String? = #function,
        fn: () -> String
    ) {
        if (enabled) && (level.rawValue >= self.level.rawValue) {
            self.log(level: level, message: fn())
        }
    }
    
    open func trace(
        _ file: String? = #file,
        line: Int? = #line,
        function: String? = #function,
        _ fn: () -> String
    ) {
        log(.trace, file: file, line: line, function: function, fn: fn)
    }
    
    open func debug(
        _ file: String? = #file,
        line: Int? = #line,
        function: String? = #function,
        _ fn: () -> String
    ) {
        log(.debug, file: file, line: line, function: function, fn: fn)
    }
    
    open func info(
        _ file: String? = #file,
        line: Int? = #line,
        function: String? = #function,
        _ fn: () -> String
    ) {
        log(.info, file: file, line: line, function: function, fn: fn)
    }
    
    open func warn(
        _ file: String? = #file,
        line: Int? = #line,
        function: String? = #function,
        _ fn: () -> String
    ) {
        log(.warn, file: file, line: line, function: function, fn: fn)
    }
    
    open func error(
        _ file: String? = #file,
        line: Int? = #line,
        function: String? = #function,
        _ fn: () -> String
    ) {
        log(.error, file: file, line: line, function: function, fn: fn)
    }
    
    open func always(
        _ file: String? = #file,
        line: Int? = #line,
        function: String? = #function,
        _ fn: () -> String
    ) {
        log(.always, file: file, line: line, function: function, fn: fn)
    }
    
}

// MARK: -

extension Logger {
    
    open func setLog(level: LogLevel,
        file: String? = #file,
        line: Int? = #line,
        function: String? = #function
    ) {
        self.level = level
        self.log(level: .always, message: "Log level is \(level)",
            file: file, line: line, function: function
        )
    }
    
    open func setLog(level string: String?,
        file: String? = #file,
        line: Int? = #line,
        function: String? = #function
    ) {
        if let string = string {
            switch string.lowercased() {
            case "trace": level = .trace
            case "debug": level = .debug
            case "info": level = .info
            case "warn": level = .warn
            case "error": level = .error
            case "always": level = .always
            default:
                level = .error
                Log.error("Invalid log level: \(string)")
            }
        }
        else {
            level = .warn
        }
        self.log(level: .always, message: "Log level is \(level)",
            file: file, line: line, function: function
        )
    }
    
}
