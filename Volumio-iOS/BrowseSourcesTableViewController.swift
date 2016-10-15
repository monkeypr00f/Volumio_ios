//
//  BrowseSourcesTableViewController.swift
//  Volumio-iOS
//
//  Created by Federico Sintucci on 01/10/16.
//  Copyright © 2016 Federico Sintucci. All rights reserved.
//

import UIKit

class BrowseSourcesTableViewController: UITableViewController {
    
    var sourcesList : [SourceObject] = []

    override func viewWillAppear(_ animated: Bool) {
        SocketIOManager.sharedInstance.browseSources()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("browseSources"), object: nil, queue: nil, using: { notification in
            if let sources = SocketIOManager.sharedInstance.currentSources {
                self.sourcesList = sources
                self.tableView.reloadData()
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
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sourcesList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "source", for: indexPath)
        let source = sourcesList[indexPath.row]
        
        cell.textLabel?.text = source.name

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let pluginName = sourcesList[indexPath.row].plugin_name {
            switch pluginName {
                case "mpd": performSegue(withIdentifier: "showMpd", sender: self)
                case "last_100": performSegue(withIdentifier: "showLast100", sender: self)
                case "webradio": performSegue(withIdentifier: "showWebRadio", sender: self)
                case "spop": performSegue(withIdentifier: "showSpotify", sender: self)
            default: performSegue(withIdentifier: "showFavourites", sender: self)
            }
        }
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        self.tableView.reloadData()
        refreshControl.endRefreshing()
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showFavourites" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let destinationController = segue.destination as! BrowseFavouritesTableViewController
                destinationController.serviceName = sourcesList[indexPath.row].name
                destinationController.serviceUri = sourcesList[indexPath.row].uri
            }
        }
        
        if segue.identifier == "showSpotify" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let destinationController = segue.destination as! BrowseSpotifyTableViewController
                destinationController.serviceName = sourcesList[indexPath.row].name
                destinationController.serviceUri = sourcesList[indexPath.row].uri
            }
        }
    }

}
