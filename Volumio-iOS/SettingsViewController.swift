//
//  SettingsViewController.swift
//  Volumio-iOS
//
//  Created by Federico Sintucci on 09/10/16.
//  Copyright © 2016 Federico Sintucci. All rights reserved.
//

import UIKit
import Eureka
import Kingfisher

class SettingsViewController: FormViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        form = Section("Plugins")
            <<< ButtonRow("Installed") { (row: ButtonRow) -> Void in
                row.title = row.tag
                row.presentationMode = .segueName(segueName: "pluginsSettings", onDismiss: nil)
            }.cellSetup { cell, row in
                cell.imageView?.image = UIImage(named: "plugins")
            }
            
            +++ Section("System")
            <<< ButtonRow("Network") { (row: ButtonRow) -> Void in
                row.title = row.tag
                row.presentationMode = .segueName(segueName: "networkSettings", onDismiss: nil)
                }.cellSetup { cell, row in
                    cell.imageView?.image = UIImage(named: "network")
            }
            <<< ButtonRow("Shutdown") {
                $0.title = $0.tag
                }.onCellSelection { [weak self] (cell, row) in
                    self?.shutdownAlert()
            }
        
            +++ Section("Debug")
            <<< ButtonRow("Switch Device") {
                $0.title = $0.tag
                }.onCellSelection{ [weak self] (cell, row) in
                    UserDefaults.standard.removeObject(forKey: "selectedPlayer")
                    let controller = self?.storyboard?.instantiateViewController(withIdentifier: "SearchingViewController") as! SearchVolumioViewController
                    self?.present(controller, animated: true, completion: nil)
            }
            <<< ButtonRow("Clear cache") {
                $0.title = $0.tag
                }.onCellSelection { [weak self] (cell, row) in
                    self?.clearImageCache()
            }
            <<< ButtonRow("Clear user settings") {
                $0.title = $0.tag
                }.onCellSelection { [weak self] (cell, row) in
                    self?.clearUserSettings()
            }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func clearImageCache() {
        ImageCache.default.clearDiskCache(completion: { (data) in
            ImageCache.default.clearMemoryCache()
        })
    }
    
    func clearUserSettings() {
        UserDefaults.standard.removeObject(forKey: "hideSwipeTutorial")
    }
    
    func shutdownAlert() {
        let alert = UIAlertController(title: "Volumio", message: "", preferredStyle: .alert)
        alert.addAction(
            UIAlertAction(title: "Shutdown", style: .default, handler: { (action) in
                SocketIOManager.sharedInstance.doAction(action: "shutdown")
            })
        )
        alert.addAction(
            UIAlertAction(title: "Reboot", style: .default, handler: { (action) in
                SocketIOManager.sharedInstance.doAction(action: "reboot")
            })
        )
        alert.addAction(
            UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        )
        self.present(alert, animated: true, completion: nil)
    }

}
