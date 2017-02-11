//
//  NetworksTableViewController.swift
//  Volumio
//
//  Created by Federico Sintucci on 21/10/16.
//  Copyright © 2016 Federico Sintucci. All rights reserved.
//

import UIKit

class NetworksTableViewController: UITableViewController {
    
    var networksData : [[NetworkObject]] = []

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        networksData.removeAll()
        
        registerObservers()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        VolumioIOManager.shared.getInfoNetwork()
        VolumioIOManager.shared.getWirelessNetworks()
        
        pleaseWait()
        
        refreshControl?.addTarget(self,
            action: #selector(handleRefresh),
            for: UIControlEvents.valueChanged
        )
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        clearAllNotice()
        
        NotificationCenter.default.removeObserver(self)
    }

    private func registerObservers() {
        NotificationCenter.default.addObserver(self,
            selector: #selector(getNetworks(notification:)),
            name: .browseNetwork,
            object: nil
        )
        NotificationCenter.default.addObserver(self,
            selector: #selector(getWireless(notification:)),
            name: .browseWifi,
            object: nil
        )
    }
    
    func getNetworks(notification: NSNotification) {
        guard let sources = notification.object as? [NetworkObject] else { return }
        
        networksData.append(sources)
        tableView.reloadData()
    }

    func getWireless(notification: NSNotification) {
        guard let sources = notification.object as? [NetworkObject] else { return }
        
        networksData.append(sources)
        tableView.reloadData()
        clearAllNotice()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return networksData.count
    }

    override func tableView(_ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return networksData[section].count
    }
    
    override func tableView(_ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "connection", for: indexPath)
        
        let type = networksData[indexPath.section]
        let source = type[indexPath.row]
        
        cell.textLabel?.text = source.ssid
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView,
        titleForHeaderInSection section: Int
    ) -> String? {
        switch section {
        case 0: return localizedNetworkInfoTitle
        case 1: return localizedWirelessNetworksTitle
        default: return ""
        }
    }

    func handleRefresh(refreshControl: UIRefreshControl) {
        
        networksData.removeAll()
        tableView.reloadData()
        
        VolumioIOManager.shared.getInfoNetwork()
        VolumioIOManager.shared.getWirelessNetworks()

        refreshControl.endRefreshing()
    }

}

// MARK: - Localization

extension NetworksTableViewController {
    
    fileprivate var localizedNetworkInfoTitle: String {
        return NSLocalizedString("NETWORKS_NETWORK_INFO",
            comment: "network info title"
        )
    }
    
    fileprivate var localizedWirelessNetworksTitle: String {
        return NSLocalizedString("NETWORKS_WIRELESS_NETWORKS",
            comment: "wireless networks title"
        )
    }

}
