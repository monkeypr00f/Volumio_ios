//
//  BrowseFavouritesTableViewController.swift
//  Volumio-iOS
//
//  Created by Federico Sintucci on 14/10/16.
//  Copyright © 2016 Federico Sintucci. All rights reserved.
//

import UIKit

class BrowseFavouritesTableViewController: UITableViewController {

    var serviceName : String!
    var serviceUri : String!
    
    var sourceLibrary : [LibraryObject] = []
    
    override func viewWillAppear(_ animated: Bool) {
        SocketIOManager.sharedInstance.browseLibrary(uri: serviceUri)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = serviceName
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("browseLibrary"), object: nil, queue: nil, using: { notification in
            if let sources = SocketIOManager.sharedInstance.currentLibrary {
                self.sourceLibrary = sources
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
        return sourceLibrary.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "library", for: indexPath)
        let library = sourceLibrary[indexPath.row]
        
        cell.textLabel?.text = library.title ?? ""
        
        return cell
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        self.tableView.reloadData()
        refreshControl.endRefreshing()
    }
}
