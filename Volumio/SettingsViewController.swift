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
        clearAllNotice()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        localize()

        form = Section(localizedSystemSectionTitle)
            <<< ButtonRow(localizedInstalledPluginsTitle) { (row: ButtonRow) -> Void in
                row.title = row.tag
                row.presentationMode = .segueName(segueName: "pluginsSettings", onDismiss: nil)
            }.cellSetup { cell, row in
                cell.imageView?.image = UIImage(named: "plugins")
            }
            
            <<< ButtonRow(localizedOpenWebUITitle) {
                $0.title = $0.tag
                }.onCellSelection {(cell, row) in
                    UIApplication.shared.open(
                        // FIXME: use actual player url, different players have different urls 
                        URL(string: "http://volumio.local")!,
                        options: [:],
                        completionHandler: nil
                    )
                }
            
//            <<< ButtonRow("Network") { (row: ButtonRow) -> Void in
//                row.title = row.tag
//                row.presentationMode = .segueName(segueName: "networkSettings", onDismiss: nil)
//                }.cellSetup { cell, row in
//                    cell.imageView?.image = UIImage(named: "network")
//            }
            
            +++ Section("")
            <<< ButtonRow(localizedShutdownOptionsTitle) {
                $0.title = $0.tag
                }.onCellSelection { [weak self] (cell, row) in
                    self?.shutdownAlert()
            }
        
            +++ Section(localizedDebugSectionTitle)
            <<< ButtonRow(localizedChangePlayerTitle) {
                $0.title = $0.tag
                }.onCellSelection{ [weak self] (cell, row) in
                    // FIXME: handling of default should be centralized (move to manager?)
                    Defaults.remove(.selectedPlayer)
                    let controller = self?.storyboard?.instantiateViewController(withIdentifier: "SearchingViewController") as! SearchVolumioViewController
                    self?.present(controller, animated: true, completion: nil)
            }
            <<< ButtonRow(localizedClearCacheTitle) {
                $0.title = $0.tag
                }.onCellSelection { [weak self] (cell, row) in
                    self?.clearImageCache()
            }
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
        alert.addAction(UIAlertAction(title: localizedShutdownTitle, style: .default) {
            (action) in
                VolumioIOManager.shared.shutdown()
        })
        alert.addAction(UIAlertAction(title: localizedRebootTitle, style: .default) {
            (action) in
                VolumioIOManager.shared.reboot()
        })
        alert.addAction(UIAlertAction(title: localizedCancelTitle, style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }

}

// MARK: - Localization

extension SettingsViewController {
    
    fileprivate func localize() {
        navigationItem.title = NSLocalizedString("SETTINGS",
            comment: "settings view title"
        )
    }
    
    fileprivate var localizedSystemSectionTitle: String {
        return NSLocalizedString("SETTINGS_SECTION_SYSTEM",
            comment: "system"
        )
    }

    fileprivate var localizedInstalledPluginsTitle: String {
        return NSLocalizedString("SETTINGS_INSTALLED_PLUGINS",
            comment: "[trigger] show installed volumio player plugins"
        )
    }
    
    fileprivate var localizedOpenWebUITitle: String {
        return NSLocalizedString("SETTINGS_OPEN_WEBUI",
            comment: "[trigger] show volumio player web ui"
        )
    }

    fileprivate var localizedShutdownOptionsTitle: String {
        return NSLocalizedString("SETTINGS_SHUTDOWN_OPTIONS",
            comment: "[trigger] show shutdown options for volumio player"
        )
    }
    
    fileprivate var localizedShutdownTitle: String {
        return NSLocalizedString("SETTINGS_SHUTDOWN",
            comment: "[trigger] shutdown volumio player"
        )
    }
    
    fileprivate var localizedRebootTitle: String {
        return NSLocalizedString("SETTINGS_REBOOT",
            comment: "[trigger] reboot volumio player"
        )
    }
    
    fileprivate var localizedDebugSectionTitle: String {
        return NSLocalizedString("SETTINGS_SECTION_DEBUG",
            comment: "debugging"
        )
    }
    
    fileprivate var localizedChangePlayerTitle: String {
        return NSLocalizedString("SETTINGS_CHANGE_PLAYER",
            comment: "[trigger] change volumio player"
        )
    }
    fileprivate var localizedClearCacheTitle: String {
        return NSLocalizedString("SETTINGS_CLEAR_CACHE",
            comment: "[trigger] clear cache"
        )
    }

    fileprivate var localizedCancelTitle: String {
        return NSLocalizedString("CANCEL", comment: "[trigger] cancel action")
    }
    
}
