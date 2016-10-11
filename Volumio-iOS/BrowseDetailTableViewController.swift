//
//  BrowseDetailTableViewController.swift
//  Volumio-iOS
//
//  Created by Federico Sintucci on 02/10/16.
//  Copyright © 2016 Federico Sintucci. All rights reserved.
//

import UIKit

class BrowseDetailTableViewController: UITableViewController {
    
    var serviceName : String!
    var serviceUri : String!
    
    var sourceLibrary : [LibraryObject] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = serviceName
        SocketIOManager.sharedInstance.browseLibrary(uri: serviceUri)
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("browseLibrary"), object: nil, queue: nil, using: { notification in
            if let sources = SocketIOManager.sharedInstance.currentLibrary {
                self.sourceLibrary = sources
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
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sourceLibrary.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "library", for: indexPath)
        let library = sourceLibrary[indexPath.row]
        
        cell.textLabel?.text = library.title ?? ""
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 3:
            performSegue(withIdentifier: "browsePlaylist", sender: self)
        default:
            performSegue(withIdentifier: "showPlaylist", sender: self)
        }
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "browsePlaylist" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let destinationController = segue.destination as! BrowsePlaylistDetailTableViewController
                destinationController.serviceName = sourceLibrary[indexPath.row].title
                destinationController.serviceUri = sourceLibrary[indexPath.row].uri
            }
        }
        
        if segue.identifier == "showPlaylist" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let destinationController = segue.destination as! PlaylistTableViewController
                destinationController.serviceName = sourceLibrary[indexPath.row].title
                destinationController.serviceUri = sourceLibrary[indexPath.row].uri
            }
        }
    }

}
