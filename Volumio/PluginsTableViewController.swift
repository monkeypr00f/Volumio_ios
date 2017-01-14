//
//  PluginsTableViewController.swift
//  Volumio
//
//  Created by Federico Sintucci on 12/10/16.
//  Copyright © 2016 Federico Sintucci. All rights reserved.
//

import UIKit

class PluginsTableViewController: UITableViewController {
    
    var pluginsList : [PluginObject] = []
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        VolumioIOManager.shared.getInstalledPlugins()
        
        registerObservers()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        localize()
        
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
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
            selector: #selector(updateSources(notification:)),
            name: .browsePlugins,
            object: nil
        )
    }
    
    func updateSources(notification: NSNotification) {
        guard let sources = notification.object as? [PluginObject] else { return }
        
        pluginsList = sources
        tableView.reloadData()
        clearAllNotice()
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
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        VolumioIOManager.shared.getInstalledPlugins()
        refreshControl.endRefreshing()
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "pluginDetail" {
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            
            let destinationController = segue.destination as! PluginDetailViewController
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
