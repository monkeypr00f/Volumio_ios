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
    
    override func viewDidAppear(_ animated: Bool) {
        ImageCache.default.calculateDiskCacheSize { size in
            print("\(size/1000/1000) MB")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        form = Section("Plugins")
            <<< ButtonRow("Installed") { (row: ButtonRow) -> Void in
                row.title = row.tag
                row.presentationMode = .segueName(segueName: "pluginsSettings", onDismiss: nil)
            }.cellSetup { cell, row in
                cell.imageView?.image = UIImage(named: "plugins")
            }
            <<< ButtonRow("Clear cache") {
                $0.title = $0.tag
                }.onCellSelection { [weak self] (cell, row) in
                    self?.clearImageCache()
            }
            
            +++ Section("System")
            <<< ButtonRow("Shutdown") {
                $0.title = $0.tag
                }.onCellSelection { [weak self] (cell, row) in
                    self?.shutdownAlert()
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
    

    // MARK: - Navigation

}
