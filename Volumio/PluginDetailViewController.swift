//
//  PluginDetailViewController.swift
//  Volumio
//
//  Created by Federico Sintucci on 12/10/16.
//  Copyright © 2016 Federico Sintucci. All rights reserved.
//

import UIKit
import Eureka

class PluginDetailViewController: FormViewController {

    var service : PluginObject!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = service.prettyName
        
        form +++ Section("")
            <<< LabelRow() {
                $0.title = "Version"
                $0.value = service.version
            }
        
            <<< SwitchRow() {
                $0.title = "Status"
                if service.enabled == 1 {
                    $0.value = true
                } else {
                    $0.value = false
                }
                }.onChange { [weak self] row in
                    if row.value ?? false {
                        SocketIOManager.sharedInstance.togglePlugin(name: (self?.service.name)!, category: (self?.service.category)!, action: "enable")
                    } else {
                        SocketIOManager.sharedInstance.togglePlugin(name: (self?.service.name)!, category: (self?.service.category)!, action: "disable")
                    }
                }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
