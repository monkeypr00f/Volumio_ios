//
//  TabBarViewController.swift
//  Volumio
//
//  Created by Federico Sintucci on 01/10/16.
//  Copyright © 2016 Federico Sintucci. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        localize()
        
        self.tabBar.tintColor = UIColor.black
    }
}

// MARK: - Localization

extension TabBarViewController {
    
    fileprivate func localize() {
        if let items = self.tabBar.items {
            if let item = items[safe: 0] {
                item.title = NSLocalizedString("PLAYBACK",
                    comment: "[trigger](short) show playback view"
                )
            }
            if let item = items[safe: 1] {
                item.title = NSLocalizedString("QUEUE",
                    comment: "[trigger](short) show queue view"
                )
            }
            if let item = items[safe: 2] {
                item.title = NSLocalizedString("BROWSE",
                    comment: "[trigger](short) show browse view"
                )
            }
            if let item = items[safe: 3] {
                item.title = NSLocalizedString("SETTINGS",
                    comment: "[trigger](short) show settings view"
                )
            }
        }
    }
    
}
