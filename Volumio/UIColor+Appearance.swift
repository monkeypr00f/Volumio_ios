//
//  UIColor+Appearance.swift
//  Volumio
//
//  Created by Michael Baumgärtner on 09.02.17.
//  Copyright © 2017 Federico Sintucci. All rights reserved.
//

import UIKit

extension UIColor {
    
    class var playButtonBackground: UIColor {
        return #colorLiteral(red: 0.2901960784, green: 0.7450980392, blue: 0.5254901961, alpha: 1)
    }
    
    class var moreButtonBackground: UIColor {
        return #colorLiteral(red: 0.2980392157, green: 0.2784313725, blue: 0.2745098039, alpha: 1)
    }

    class var selectPlayerCellBorder: UIColor {
        return #colorLiteral(red: 0.6352941176, green: 0.6078431373, blue: 0.6039215686, alpha: 1)
    }

    class var addToPlaylistCellBorder: UIColor {
        // pink flare
        return #colorLiteral(red: 0.7490196078, green: 0.7215686275, blue: 0.7254901961, alpha: 1)
    }

}
