//
//  Logging.swift
//  Simple logging with colorful symbols.
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
	
	var color: (Int, Int, Int) {
		switch self {
		case .trace:  return (149, 165, 166) // concrete
		case .debug:  return (127, 140, 141) // asbestos
		case .info:   return ( 46, 204, 113) // emerald
		case .warn:   return (243, 156,  18) // gamboge
		case .error:  return (231,  76,  60) // alizarin
		case .always: return ( 52, 152, 219) // river
		}
	}
	
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
	
	open var colorText  = ( 52,  73,  94) // asphalt
	open var colorLight = (149, 165, 166) // concrete
	
	var enabled: Bool
	
    // not supported as long as xcode does not support ansi colors in its console:
	var colorize: Bool = false
    
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
			var infoString = "[\(self.name)][\(f):\(fn):\(l)]"
			var levelString = String(describing: logLevel).uppercased()
			var messageString = "\(logMessage())"
//			if colorize {
//				infoString = String.foregroundColor(infoString, colorLight)
//				levelString = String.foregroundColor(levelString, logLevel.color)
//				messageString = String.foregroundColor(messageString, colorText)
//			}
			if let symbol = logLevel.symbol {
				levelString = symbol + levelString
			}
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
