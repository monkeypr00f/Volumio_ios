//
//  UIApplication+Dispatch.swift
//
//  Created by Michael Baumgärtner on 26.09.16.
//  Copyright © 2016 Michael Baumgärtner. All rights reserved.
//

import UIKit

// MARK: - Convenience (GCD)

public extension UIApplication {

    public class func main(after seconds: Double? = nil, block: @escaping () -> Void) {
        if let seconds = seconds {
            DispatchQueue.main.asyncAfter(deadline: .now() + seconds) { block() }
        } else {
            DispatchQueue.main.async { block() }
        }
    }

}
