//
//  PluginsTableViewController.swift
//  Volumio-iOS
//
//  Created by Federico Sintucci on 12/10/16.
//  Copyright © 2016 Federico Sintucci. All rights reserved.
//

import UIKit

class PluginsTableViewController: UITableViewController {
    
    var pluginsList : [[String:Any]] = []
    
    override func viewWillAppear(_ animated: Bool) {
        SocketIOManager.sharedInstance.getInstalledPlugins()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("browsePlugins"), object: nil, queue: nil, using: { notification in
            if let sources = SocketIOManager.sharedInstance.installedPlugins {
                self.pluginsList = sources
                self.tableView.reloadData()
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "plugins", for: indexPath)
        let source = pluginsList[indexPath.row]
        
        cell.textLabel?.text = source["prettyName"] as! String?

        return cell
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "pluginDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let destinationController = segue.destination as! PluginDetailViewController
                destinationController.servicePrettyName = pluginsList[indexPath.row]["prettyName"] as! String
                destinationController.serviceName = pluginsList[indexPath.row]["name"] as! String
                destinationController.serviceCategory = pluginsList[indexPath.row]["category"] as! String
                destinationController.serviceActive = pluginsList[indexPath.row]["active"] as! Int
                destinationController.serviceEnabled = pluginsList[indexPath.row]["enabled"] as! Int
            }
        }
    }

}
