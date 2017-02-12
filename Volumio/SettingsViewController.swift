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

class SettingsViewController: VolumioFormViewController {

    // MARK: - View Callbacks

    override func viewDidLoad() {
        super.viewDidLoad()

        localize()

        form = Section(localizedSystemSectionTitle)
            <<< ButtonRow(localizedInstalledPluginsTitle) { (row: ButtonRow) -> Void in
                row.title = row.tag
                row.presentationMode = .segueName(segueName: "pluginsSettings", onDismiss: nil)
            }.cellSetup { (cell, _) in
                cell.imageView?.image = UIImage(named: "plugins")
            }

            <<< ButtonRow(localizedOpenWebUITitle) {
                $0.title = $0.tag
            }.onCellSelection { _ in
                guard let playerURL = VolumioIOManager.shared.currentPlayer?.url
                    else { return }
                UIApplication.shared.open(playerURL, options: [:], completionHandler: nil)
            }

            +++ Section("")
            <<< ButtonRow(localizedShutdownOptionsTitle) {
                $0.title = $0.tag
            }.onCellSelection { [weak self] _ in
                self?.shutdownAlert()
            }

            +++ Section(localizedDebugSectionTitle)
            <<< ButtonRow(localizedChangePlayerTitle) {
                $0.title = $0.tag
            }.onCellSelection{ _ in
                VolumioIOManager.shared.disconnect(unsetDefault: true)
            }
            <<< ButtonRow(localizedClearCacheTitle) {
                $0.title = $0.tag
            }.onCellSelection { [weak self] _ in
                self?.clearImageCache()
            }
    }

    // MARK: -

    func clearImageCache() {
        ImageCache.default.calculateDiskCacheSize { (size) in
            Log.info("Used disk cache size by bytes: \(size / 1_000_000)")

            ImageCache.default.clearDiskCache(completion: { _ in
                ImageCache.default.clearMemoryCache()
            })
        }
    }

    func shutdownAlert() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: localizedShutdownTitle, style: .default) { _ in
            VolumioIOManager.shared.shutdown()
        })
        alert.addAction(UIAlertAction(title: localizedRebootTitle, style: .default) { _ in
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
