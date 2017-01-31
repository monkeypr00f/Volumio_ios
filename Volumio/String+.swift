//
//  String+.swift
//  Volumio
//
//  Created by Michael Baumgärtner on 01.02.17.
//  Copyright © 2017 Federico Sintucci. All rights reserved.
//

import Foundation

extension String {
    
    /// Returns true if the specified string contains only whitespace characters or is empty.
    var isBlank: Bool {
        return trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty
    }
}
