//
//  TabBarViewController.swift
//  Volumio-iOS
//
//  Created by Federico Sintucci on 01/10/16.
//  Copyright © 2016 Federico Sintucci. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.tabBar.tintColor = UIColor.black
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("disconnected"), object: nil, queue: nil, using: { notification in
            self.performSegue(withIdentifier: "segueToLoading", sender: self)
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
