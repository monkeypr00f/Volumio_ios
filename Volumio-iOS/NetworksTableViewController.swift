//
//  NetworksTableViewController.swift
//  Volumio-iOS
//
//  Created by Federico Sintucci on 21/10/16.
//  Copyright © 2016 Federico Sintucci. All rights reserved.
//

import UIKit

class NetworksTableViewController: UITableViewController {
    
    var networksData : [[NetworkObject]] = []
    
    override func viewWillAppear(_ animated: Bool) {
        networksData.removeAll()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        SocketIOManager.sharedInstance.getInfoNetwork()
        SocketIOManager.sharedInstance.getWirelessNetworks()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.pleaseWait()
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("browseNetwork"), object: nil, queue: nil, using: { notification in
            if let sources = SocketIOManager.sharedInstance.connectedNetwork {
                self.networksData.append(sources)
                self.tableView.reloadData()
            }
        })
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("browseWifi"), object: nil, queue: nil, using: { notification in
            if let sources = SocketIOManager.sharedInstance.wirelessNetwork {
                self.networksData.append(sources)
                self.tableView.reloadData()
                self.clearAllNotice()
            }
        })
        
        self.refreshControl?.addTarget(self, action: #selector(handleRefresh), for: UIControlEvents.valueChanged)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        SocketIOManager.sharedInstance.getInfoNetwork()
        SocketIOManager.sharedInstance.getWirelessNetworks()

        refreshControl.endRefreshing()
    }

}
