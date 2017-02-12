//
//  PlayerSettingsViewController.swift
//  Volumio
//
//  Created by Michael Baumgärtner on 01.02.17.
//  Copyright © 2017 Federico Sintucci. All rights reserved.
//

import UIKit

import Eureka

protocol PlayerSettingsDelegate: class {

    /// Called when the user cancelled the player settings view
    func didCancel(on playerSettings: PlayerSettingsViewController)

    /// Called right after the user confirmed the player’s settings. Return true, if the settings are valid.
    func willAccept(player: Player,
        on playerSettings: PlayerSettingsViewController
    ) -> Bool

    /// Called just before dismissing the player settings view after the user confirmed the player’s settings and they are valid.
    func didFinish(with player: Player,
        on playerSettings: PlayerSettingsViewController
    )

}

class PlayerSettingsViewController: FormViewController, ShowsNotices {

    weak var delegate: PlayerSettingsDelegate?

    @IBOutlet weak fileprivate var cancelBarButtonItem: UIBarButtonItem!
    @IBOutlet weak fileprivate var connectBarButtonItem: UIBarButtonItem!

    var formName: String? {
        guard let row = form.rowBy(tag: "player_name") as? TextRow else { return nil }
        return row.value
    }

    var formHost: String? {
        guard let row = form.rowBy(tag: "player_host") as? TextRow else { return nil }
        return row.value
    }

    var formPort: Int? {
        guard let row = form.rowBy(tag: "player_port") as? IntRow else { return nil }
        return row.value
    }

    // MARK: - View Callbacks

    override func viewDidLoad() {
        super.viewDidLoad()

        localize()

        let defaultPlayer = VolumioIOManager.shared.defaultPlayer

        form +++ Section()
            <<< TextRow("player_name") { row in
                row.title = localizedPlayerNameTitle
                row.placeholder = localizedPlayerNamePlaceholder
                row.value = defaultPlayer?.name
                row.add(rule: RuleRequired())
                row.validationOptions = .validatesOnChange
            }
            .cellUpdate { cell, row in
                if row.wasChanged && !row.isValid {
                    cell.titleLabel?.textColor = .red
                }
                self.updateConnectButtonState()
            }
            <<< TextRow("player_host") { row in
                row.title = localizedPlayerHostTitle
                row.placeholder = localizedPlayerHostPlaceholder
                row.value = defaultPlayer?.host
                row.add(rule: RuleRequired())
                row.validationOptions = .validatesOnChange
            }
            .cellUpdate { cell, row in
                if row.wasChanged && !row.isValid {
                    cell.titleLabel?.textColor = .red
                }
                self.updateConnectButtonState()
            }
            <<< IntRow("player_port") { row in
                row.title = localizedPlayerPortTitle
                row.placeholder = localizedPlayerPortPlaceholder
                row.value = defaultPlayer?.port
                row.add(rule: RuleRequired())
                row.add(rule: RuleGreaterThan(min: 0))
                row.add(rule: RuleSmallerThan(max: 65_536))
                row.validationOptions = .validatesOnChange
                let formatter = NumberFormatter()
                formatter.groupingSeparator = ""
                row.formatter = formatter
            }
            .cellUpdate { cell, row in
                if row.wasChanged && !row.isValid {
                    cell.titleLabel?.textColor = .red
                }
                self.updateConnectButtonState()
            }

        updateConnectButtonState()
    }

    // MARK: - View Updates

    func updateConnectButtonState() {
        connectBarButtonItem.isEnabled = form.validate().isEmpty
    }

    // MARK: - View Actions

    @IBAction func dismiss(_ sender: Any) {
        guard let delegate = delegate else { return }

        delegate.didCancel(on: self)
    }

    @IBAction func connect(_ sender: Any) {
        guard let delegate = delegate else { return }

        guard let name = formName, let host = formHost, let port = formPort
            else { return }

        let player = Player(name: name, host: host, port: port)

        if delegate.willAccept(player: player, on: self) {
            delegate.didFinish(with: player, on: self)
        } else {
            notice(error: localizedPlayerSettingsInvalid)
        }
    }

}

// MARK: - Localization

extension PlayerSettingsViewController {

    fileprivate func localize() {
        cancelBarButtonItem.title = localizedCancelTitle
        connectBarButtonItem.title = localizedConnectTitle
    }

    fileprivate var localizedPlayerNameTitle: String {
        return NSLocalizedString("PLAYER_SETTINGS_NAME_TITLE",
            comment: "[input] label for player name setting"
        )
    }
    fileprivate var localizedPlayerNamePlaceholder: String {
        return NSLocalizedString("PLAYER_SETTINGS_NAME_PLACEHOLDER",
            comment: "[input] placeholder for player name setting"
        )
    }

    fileprivate var localizedPlayerHostTitle: String {
        return NSLocalizedString("PLAYER_SETTINGS_HOST_TITLE",
            comment: "[input] label for player host setting"
        )
    }
    fileprivate var localizedPlayerHostPlaceholder: String {
        return NSLocalizedString("PLAYER_SETTINGS_HOST_PLACEHOLDER",
            comment: "[input] placeholder for player host setting"
        )
    }

    fileprivate var localizedPlayerPortTitle: String {
        return NSLocalizedString("PLAYER_SETTINGS_PORT_TITLE",
            comment: "[input] label for player port setting"
        )
    }
    fileprivate var localizedPlayerPortPlaceholder: String {
        return NSLocalizedString("PLAYER_SETTINGS_PORT_PLACEHOLDER",
            comment: "[input] placeholder for player port setting"
        )
    }

    fileprivate var localizedPlayerSettingsInvalid: String {
        return NSLocalizedString("PLAYER_INVALID_SETTINGS",
            comment: "settings (name, host or port) for player are invalid"
        )
    }

    fileprivate var localizedCancelTitle: String {
        return NSLocalizedString("CANCEL", comment: "[trigger] cancel action")
    }

    fileprivate var localizedConnectTitle: String {
        return NSLocalizedString("CONNECT", comment: "[trigger] connect action")
    }

}
