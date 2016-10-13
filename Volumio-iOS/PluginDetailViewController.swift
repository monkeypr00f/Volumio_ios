//
//  PluginDetailViewController.swift
//  Volumio-iOS
//
//  Created by Federico Sintucci on 12/10/16.
//  Copyright © 2016 Federico Sintucci. All rights reserved.
//

import UIKit
import Eureka

class PluginDetailViewController: FormViewController {

    var servicePrettyName : String!
    var serviceName : String!
    var serviceCategory : String!
    var serviceActive : Int!
    var serviceEnabled : Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = servicePrettyName
        
        form +++ Section("")
            <<< LabelRow("pluginStatus") {
                $0.title = "Current Status"
                if serviceActive == 1 {
                    $0.value = "Active"
                } else {
                    $0.value = "Inactive"
                }
            }
        
            <<< SwitchRow() {
                $0.title = "Enabled"
                if serviceEnabled == 1 {
                    $0.value = true
                } else {
                    $0.value = false
                }
                }.onChange { [weak self] row in
                    
                    if row.value ?? false {
                        SocketIOManager.sharedInstance.togglePlugin(name: (self?.serviceName)!, category: (self?.serviceCategory)!, action: "disable")
                        self?.form.rowBy(tag: "pluginStatus")?.updateCell()
                    } else {
                        SocketIOManager.sharedInstance.togglePlugin(name: (self?.serviceName)!, category: (self?.serviceCategory)!, action: "enable")
                        self?.form.rowBy(tag: "pluginStatus")?.updateCell()
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
