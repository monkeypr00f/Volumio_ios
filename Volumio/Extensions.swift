//
//  Extensions.swift
//  Volumio
//
//  Created by Federico Sintucci on 17/10/16.
//  Copyright © 2016 Federico Sintucci. All rights reserved.
//

import UIKit

class Extensions: NSObject {
}

// MARK: - Swift

extension String {
    
    /// Returns true if the specified string contains only whitespace characters or is empty.
    var isBlank: Bool {
        return trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty
    }
}

// MARK: - UIKit

extension UIView {
    func makeCircle() {
        self.layer.cornerRadius = self.frame.size.width/2
        self.clipsToBounds = true
    }
}

