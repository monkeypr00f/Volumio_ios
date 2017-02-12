//
//  PluginsTableViewController.swift
//  Volumio
//
//  Created by Federico Sintucci on 12/10/16.
//  Copyright © 2016 Federico Sintucci. All rights reserved.
//

import UIKit

class PluginsTableViewController: UITableViewController, ObservesNotifications {

    var pluginsList: [PluginObject] = []

    var observers: [AnyObject] = []

    // MARK: View Callbacks

    override func viewDidLoad() {
        super.viewDidLoad()

        localize()

        tableView.tableFooterView = UIView(frame: CGRect.zero)

        refreshControl?.addTarget(self,
            action: #selector(handleRefresh),
            for: UIControlEvents.valueChanged
        )
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        registerObserver(forName: .browsePlugins) { (notification) in
            self.clearAllNotice()

            guard let plugins = notification.object as? [PluginObject]
                else { return }
            self.pluginsList = plugins
            self.updatePlugins()
        }

        pleaseWait()
    }

    override func viewDidAppear(_ animated: Bool) {
        if !VolumioIOManager.shared.isConnected && !VolumioIOManager.shared.isConnecting {
            _ = navigationController?.popToRootViewController(animated: animated)
        } else {
            VolumioIOManager.shared.getInstalledPlugins()
        }
        super.viewDidAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        clearAllNotice()

        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - View Update

    func updatePlugins() {
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pluginsList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let anyCell = tableView.dequeueReusableCell(withIdentifier: "plugins", for: indexPath)
        guard let cell = anyCell as? PluginTableViewCell
            else { fatalError() }

        let source = pluginsList[indexPath.row]

        cell.pluginName.text = source.prettyName
        if source.active == 1 {
            cell.pluginStatus.backgroundColor = UIColor.green
        } else {
            cell.pluginStatus.backgroundColor = UIColor.red
        }

        return cell
    }

    func handleRefresh(refreshControl: UIRefreshControl) {
        VolumioIOManager.shared.getInstalledPlugins()
        refreshControl.endRefreshing()
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "pluginDetail" {
            guard let destinationController = segue.destination as? PluginDetailViewController
                else { fatalError() }

            guard let indexPath = tableView.indexPathForSelectedRow else { return }

            destinationController.plugin = pluginsList[indexPath.row]
        }
    }

}

// MARK: - Localization

extension PluginsTableViewController {

    fileprivate func localize() {
        navigationItem.title = NSLocalizedString("PLUGINS",
            comment: "plugins view title"
        )
    }

}
