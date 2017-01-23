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

    var plugin : PluginObject!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = plugin.prettyName
        
        form +++ Section("")
            <<< LabelRow() {
                $0.title = localizedVersionTitle
                $0.value = plugin.version
            }
        
            <<< SwitchRow() {
                $0.title = localizedStatusTitle
                $0.value = plugin.enabled == 1
                }.onChange { [weak self] row in
                    guard let plugin = self?.plugin
                        else { return }
                    guard let name = plugin.name, let category = plugin.category
                        else { return }
                    
                    VolumioIOManager.shared.togglePlugin(
                        name: name,
                        category: category,
                        action: (row.value ?? false) ? "enable" : "disable"
                    )
                }
    }

}

// MARK: - Localization

extension PluginDetailViewController {
    
    fileprivate func localize() {
        navigationItem.title = NSLocalizedString("PLUGIN",
            comment: "plugin view title"
        )
    }

    fileprivate var localizedVersionTitle: String {
        return NSLocalizedString("PLUGIN_VERSION", comment: "volumio player’s plugin version")
    }
    
    fileprivate var localizedStatusTitle: String {
        return NSLocalizedString("PLUGIN_STATUS", comment: "volumio player’s plugin status")
    }
    
}
