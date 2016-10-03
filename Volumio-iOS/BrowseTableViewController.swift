//
//  BrowseTableViewController.swift
//  Volumio-iOS
//
//  Created by Federico Sintucci on 01/10/16.
//  Copyright © 2016 Federico Sintucci. All rights reserved.
//

import UIKit

class BrowseTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        SocketIOManager.sharedInstance.browseSources()
        tableView.tableFooterView = UIView(frame: CGRect.zero)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = SocketIOManager.sharedInstance.currentSources?.count {
            return count
        } else {
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "source", for: indexPath)
        let source = SocketIOManager.sharedInstance.currentSources?[indexPath.row]
        
        cell.textLabel?.text = source?["name"] as! String?
        cell.detailTextLabel?.text = source?["uri"] as! String?

        return cell
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "browseService" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let destinationController = segue.destination as! BrowseDetailTableViewController
                destinationController.serviceName = SocketIOManager.sharedInstance.currentSources?[indexPath.row]["name"] as! String
                destinationController.serviceUri = SocketIOManager.sharedInstance.currentSources?[indexPath.row]["uri"] as! String
            }
        }
    }

}
