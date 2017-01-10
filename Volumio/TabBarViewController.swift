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

        self.tabBar.tintColor = UIColor.black

        // L18N
        if let items = self.tabBar.items {
            if let item = items[safe: 0] {
                item.title = NSLocalizedString("PLAYBACK", comment: "playback view label")
            }
            if let item = items[safe: 1] {
                item.title = NSLocalizedString("QUEUE", comment: "queue view label")
            }
            if let item = items[safe: 2] {
                item.title = NSLocalizedString("BROWSE", comment: "browse view label")
            }
            if let item = items[safe: 3] {
                item.title = NSLocalizedString("SETTINGS", comment: "settings view label")
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
