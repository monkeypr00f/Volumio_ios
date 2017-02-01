//
//  DefaultStringConvertible.swift
//
//  Created by Michael Baumgärtner on 17.11.16.
//  Copyright © 2016 Michael Baumgärtner. All rights reserved.
//

public protocol DefaultStringConvertible {
}

public extension DefaultStringConvertible {
    
    public var defaultDescription: String {
        return generateDescription(self)
    }
    
    public var defaultDebugDescription: String {
        return generateDebugDescription(self)
    }
    
    public var description: String {
        return defaultDescription
    }
    
    public var debugDescription: String {
        return defaultDebugDescription
    }
    
}

private func generateDescription(_ any: Any) -> String {
    let mirror = Mirror(reflecting: any)
    var children = Array(mirror.children)
    
    var superclassMirror = mirror.superclassMirror
    repeat {
        if let superChildren = superclassMirror?.children {
            children.append(contentsOf: superChildren)
        }
        superclassMirror = superclassMirror?.superclassMirror
    } while superclassMirror != nil
    
    let chunks = children.map { (label: String?, value: Any) -> String in
        if let label = label {
            if value is String {
                return "\(label): \"\(value)\""
            }
            return "\(label): \(value)"
        }
        return "\(value)"
    }
    
    if chunks.count > 0 {
        let chunksString = chunks.joined(separator: ", ")
        return "\(mirror.subjectType)(\(chunksString))"
    }
    
    return "\(type(of: any))"
}


private func generateDebugDescription(_ any: Any) -> String {
    
    func indentedString(_ string: String) -> String {
        return string.characters
            .split(separator: "\r")
            .map(String.init)
            .map { $0.isEmpty ? "" : "\r    \($0)" }
            .joined(separator: "")
    }
    
    func unwrap(_ any: Any) -> Any? {
        let mirror = Mirror(reflecting: any)
        
        if mirror.displayStyle != .optional {
            return any
        }
        if let child = mirror.children.first , child.label == "some" {
            return unwrap(child.value)
        }
        return nil
    }
    
    guard let any = unwrap(any) else {
        return "nil"
    }
    
    if any is Void {
        return "Void"
    }
    
    if let int = any as? Int {
        return String(int)
    }
    else if let double = any as? Double {
        return String(double)
    }
    else if let float = any as? Float {
        return String(float)
    }
    else if let bool = any as? Bool {
        return String(bool)
    }
    else if let string = any as? String {
        return "\"\(string)\""
    }
    
    let mirror = Mirror(reflecting: any)
    
    var properties = Array(mirror.children)
    
    var typeName = String(describing: mirror.subjectType)
    if typeName.hasSuffix(".Type") {
        typeName = ""
    }
    else {
        typeName = "<\(typeName)> "
    }
    
    guard let displayStyle = mirror.displayStyle else {
        return "\(typeName)\(String(describing: any))"
    }
    
    switch displayStyle {
    case .tuple:
        if properties.isEmpty {
            return "()"
        }
        
        var string = "("
        
        for (index, property) in properties.enumerated() {
            if property.label!.characters.first! == "." {
                string += generateDebugDescription(property.value)
            }
            else {
                string += "\(property.label!): \(generateDebugDescription(property.value))"
            }
            
            string += (index <= properties.count ? ", " : "")
        }
        return string + ")"
        
    case .collection, .set:
        if properties.isEmpty {
            return "[]"
        }
        
        var string = "["
        for (index, property) in properties.enumerated() {
            string += indentedString(generateDebugDescription(property.value) + (index <= properties.count ? ",\r" : ""))
        }
        return string + "\r]"
        
    case .dictionary:
        if properties.isEmpty {
            return "[:]"
        }
        
        var string = "["
        for (index, property) in properties.enumerated() {
            let pair = Array(Mirror(reflecting: property.value).children)
            string += indentedString("\(generateDebugDescription(pair[0].value)): \(generateDebugDescription(pair[1].value))"
                + (index <= properties.count ? ",\r" : ""))
        }
        return string + "\r]"
        
    case .enum:
        if !(any is DefaultStringConvertible), let any = any as? CustomDebugStringConvertible {
            return any.debugDescription
        }
        
        if properties.isEmpty {
            return "\(mirror.subjectType)." + String(describing: any)
        }
        
        var string = "\(mirror.subjectType).\(properties.first!.label!)"
        let associatedValueString = generateDebugDescription(properties.first!.value)
        
        if associatedValueString.characters.first! == "(" {
            string += associatedValueString
        }
        else {
            string += "(\(associatedValueString))"
        }
        return string
        
    case .struct, .class:
        if !(any is DefaultStringConvertible), let any = any as? CustomDebugStringConvertible {
            return any.debugDescription
        }
        
        var superclassMirror = mirror.superclassMirror
        repeat {
            if let superChildren = superclassMirror?.children {
                properties.append(contentsOf: superChildren)
            }
            superclassMirror = superclassMirror?.superclassMirror
        } while superclassMirror != nil
        
        if properties.isEmpty {
            return "\(typeName)\(String(describing: any))"
        }
        
        var typeString = "\(typeName){"
        for (index, property) in properties.enumerated() {
            var propertyString = "\(property.label!): "
            if let value = unwrap(property.value) as? DefaultStringConvertible {
                propertyString += String(reflecting: value)
            }
            else {
                propertyString += generateDebugDescription(property.value)
            }
            typeString += indentedString(propertyString + (index <= properties.count ? ",\r" : ""))
        }
        return typeString + "\r}"
        
    case .optional:
        return generateDebugDescription(any)
    }
}
