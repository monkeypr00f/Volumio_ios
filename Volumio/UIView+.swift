//
//  UIView+.swift
//  Volumio
//
//  Created by Michael Baumgärtner on 01.02.17.
//  Copyright © 2017 Federico Sintucci. All rights reserved.
//

import UIKit

extension UIView {

    func makeCircle() {
        self.layer.cornerRadius = self.frame.size.width/2
        self.clipsToBounds = true
    }

}
