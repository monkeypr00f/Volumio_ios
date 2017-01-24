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

// MARK: - Foundation

extension Collection where Indices.Iterator.Element == Index {
    
    /// Returns the element at the specified index iff it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Generator.Element? {
        return indices.contains(index) ? self[index] : nil
    }

}

// MARK: - UIKit

extension UIView {
    func makeCircle() {
        self.layer.cornerRadius = self.frame.size.width/2
        self.clipsToBounds = true
    }
}

