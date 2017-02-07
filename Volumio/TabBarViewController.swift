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
                item.title = NSLocalizedString("TAB_PLAYBACK",
                    comment: "[trigger](short) show playback view"
                )
                item.accessibilityLabel = "Playback"
            }
            if let item = items[safe: 1] {
                item.title = NSLocalizedString("TAB_QUEUE",
                    comment: "[trigger](short) show queue view"
                )
                item.accessibilityLabel = "Queue"
            }
            if let item = items[safe: 2] {
                item.title = NSLocalizedString("TAB_BROWSE",
                    comment: "[trigger](short) show browse view"
                )
                item.accessibilityLabel = "Browse"
            }
            if let item = items[safe: 3] {
                item.title = NSLocalizedString("TAB_SETTINGS",
                    comment: "[trigger](short) show settings view"
                )
                item.accessibilityLabel = "Settings"
            }
        }
    }
    
}
