//
//  Item
//  Volumio
//
//  Created by Michael Baumgärtner on 23.01.17.
//  Copyright © 2017 Federico Sintucci. All rights reserved.
//

import Foundation

enum ItemType: String {
    case title
    case track
    case folder
    case playlist
    case song
    case cuesong
    case webradio
    case mywebradio
    case radio_favourites = "radio-favourites"
    case radio_category = "radio-category"
    case unknown
    
    var isSong: Bool {
        return self == .song || self == .cuesong
    }

    var isRadio: Bool {
        return self == .webradio || self == .mywebradio
    }

}
