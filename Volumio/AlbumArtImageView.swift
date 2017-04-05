//
//  AlbumArtImageView.swift
//  Volumio
//
//  Created by Michael Baumgärtner on 11.02.17.
//  Copyright © 2017 Federico Sintucci. All rights reserved.
//

import UIKit

class AlbumArtImageView: UIImageView {
}

class AlbumArtMiniImageView: UIImageView {

    override var bounds: CGRect {
        didSet {
            adjustContentMode()
        }
    }

    override var image: UIImage? {
        didSet {
            adjustContentMode()
        }
    }

    func adjustContentMode() {
        guard let image = image else { return }

        if image.size.width > bounds.size.width || image.size.height > bounds.size.height {
            contentMode = .scaleAspectFill
        } else {
            contentMode = .center
        }
    }

}
