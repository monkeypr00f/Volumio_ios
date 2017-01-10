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
        
        SocketIOManager.sharedInstance.getInfoNetwork()
        SocketIOManager.sharedInstance.getWirelessNetworks()
        
        self.pleaseWait()
        
        self.refreshControl?.addTarget(self, action: #selector(handleRefresh), for: UIControlEvents.valueChanged)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.clearAllNotice()
        NotificationCenter.default.removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func registerObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(getNetworks(notification:)), name: .browseNetwork, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(getWireless(notification:)), name: .browseWifi, object: nil)
    }
    
    func getNetworks(notification: NSNotification) {
        if let sources = notification.object as? [NetworkObject] {
            self.networksData.append(sources)
            self.tableView.reloadData()
        }
    }

    func getWireless(notification: NSNotification) {
        if let sources = notification.object as? [NetworkObject] {
            self.networksData.append(sources)
            self.tableView.reloadData()
            self.clearAllNotice()
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return networksData.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return networksData[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "connection", for: indexPath)
        let type = networksData[indexPath.section]
        let source = type[indexPath.row]
        
        cell.textLabel?.text = source.ssid
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "Network Info"
        case 1: return "Wireless Networks"
        default: return ""
        }
    }

    func handleRefresh(refreshControl: UIRefreshControl) {
        
        networksData.removeAll()
        tableView.reloadData()
        
        SocketIOManager.sharedInstance.getInfoNetwork()
        SocketIOManager.sharedInstance.getWirelessNetworks()

        refreshControl.endRefreshing()
    }

}
