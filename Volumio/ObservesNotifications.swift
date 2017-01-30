//
//  ObservesNotifications.swift
//
//  Created by Michael Baumgärtner on 16.10.16.
//  Copyright © 2016 Michael Baumgärtner. All rights reserved.
//

import Foundation

// MARK: Mixin to observe notifications

// MARK: - Protocol: ObservesNotifications

public protocol ObservesNotifications: class {
    
    var observers: [AnyObject] { get set }
    
    func registerObserver(
        forName name: NSNotification.Name,
        using block: @escaping (Notification) -> Void
    )
    
    func unregisterObservers()
}

// MARK: - Extension: ObservesNotifications

extension ObservesNotifications {
    
    public func registerObserver(
        forName name: NSNotification.Name,
        using block: @escaping (Notification) -> Void
        ) {
        let queue = OperationQueue.main
        let observer = NotificationCenter.default.addObserver(
            forName: name,
            object: nil,
            queue: queue,
            using: block
        )
        observers.append(observer)
    }
    
    public func unregisterObservers() {
        for observer in observers {
            NotificationCenter.default.removeObserver(observer)
        }
        observers.removeAll()
    }
    
}
