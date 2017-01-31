//
//  ShowsNotices.swift
//  Volumio
//
//  Created by Michael Baumgärtner on 01.02.17.
//  Copyright © 2017 Federico Sintucci. All rights reserved.
//

import UIKit

// MARK: Mixin to show notifications

// MARK: - Protocol: ShowsNotices

public protocol ShowsNotices: class {
    
    func notice(_ text: String, delayed time: Double?)

}

// MARK: - Extension: ShowsNotices

extension ShowsNotices where Self: UIViewController {
    
    func notice(_ text: String, delayed time: Double? = nil) {
        UIApplication.main(after: time) {
            self.noticeTop(text, autoClear: true, autoClearTime: 3)
        }
    }

}
