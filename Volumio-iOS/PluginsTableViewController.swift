//
//  PluginsTableViewController.swift
//  Volumio-iOS
//
//  Created by Federico Sintucci on 12/10/16.
//  Copyright © 2016 Federico Sintucci. All rights reserved.
//

import UIKit

class PluginsTableViewController: UITableViewController {
    
    var pluginsList : [PluginObject] = []
    
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "plugins", for: indexPath) as! PluginTableViewCell
        let source = pluginsList[indexPath.row]
        
        cell.pluginName.text = source.prettyName
        if source.active == 1 {
            cell.pluginStatus.backgroundColor = UIColor.green
        } else {
            cell.pluginStatus.backgroundColor = UIColor.red
        }

        return cell
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "pluginDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let destinationController = segue.destination as! PluginDetailViewController
                destinationController.service = pluginsList[indexPath.row]
            }
        }
    }

}
