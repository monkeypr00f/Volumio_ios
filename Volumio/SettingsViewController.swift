//
//  SettingsViewController.swift
//  Volumio
//
//  Created by Federico Sintucci on 09/10/16.
//  Copyright © 2016 Federico Sintucci. All rights reserved.
//

import UIKit
import Eureka
import Kingfisher

class SettingsViewController: FormViewController {
    
    override func viewDidAppear(_ animated: Bool) {
        self.clearAllNotice()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        form = Section("System")
            <<< ButtonRow("Installed plugins") { (row: ButtonRow) -> Void in
                row.title = row.tag
                row.presentationMode = .segueName(segueName: "pluginsSettings", onDismiss: nil)
            }.cellSetup { cell, row in
                cell.imageView?.image = UIImage(named: "plugins")
            }
            
            <<< ButtonRow("Open WebUI") {
                $0.title = $0.tag
                }.onCellSelection {(cell, row) in
                    UIApplication.shared.open(NSURL(string: "http://volumio.local") as! URL, options: [:], completionHandler: nil)
                }
            
//            <<< ButtonRow("Network") { (row: ButtonRow) -> Void in
//                row.title = row.tag
//                row.presentationMode = .segueName(segueName: "networkSettings", onDismiss: nil)
//                }.cellSetup { cell, row in
//                    cell.imageView?.image = UIImage(named: "network")
//            }
            
            +++ Section("")
            <<< ButtonRow("Shutdown") {
                $0.title = $0.tag
                }.onCellSelection { [weak self] (cell, row) in
                    self?.shutdownAlert()
            }
        
            +++ Section("Debug")
            <<< ButtonRow("Change Device") {
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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func clearImageCache() {
        ImageCache.default.calculateDiskCacheSize { size in
            print("Used disk size by bytes: \(size/1000000)")
            
            ImageCache.default.clearDiskCache(completion: { (data) in
                ImageCache.default.clearMemoryCache()
            })
        }
    }
    
    func shutdownAlert() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        alert.addAction(
            UIAlertAction(title: "Shutdown", style: .default, handler: { (action) in
                VolumioIOManager.shared.shutdown()
            })
        )
        alert.addAction(
            UIAlertAction(title: "Reboot", style: .default, handler: { (action) in
                VolumioIOManager.shared.reboot()
            })
        )
        alert.addAction(
            UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        )
        self.present(alert, animated: true, completion: nil)
    }

}
