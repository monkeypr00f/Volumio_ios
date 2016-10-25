//
//  BrowseSearchTableViewController.swift
//  Volumio-iOS
//
//  Created by Federico Sintucci on 22/10/16.
//  Copyright © 2016 Federico Sintucci. All rights reserved.
//

import UIKit

class BrowseSearchTableViewController: UITableViewController, UISearchBarDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    
    var sourcesList : [SearchResultObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        searchBar.delegate = self
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("browseSearch"), object: nil, queue: nil, using: { notification in
            if let sources = SocketIOManager.sharedInstance.currentSearch {
                self.sourcesList = sources
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
        return sourcesList.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sections = sourcesList[section]
        if let items = sections.items {
            return items.count
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "search", for: indexPath)
        let itemList = sourcesList[indexPath.section]
        let item = itemList.items![indexPath.row] as LibraryObject
        
        cell.textLabel?.text = item.title
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sourcesList[section].title
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        SocketIOManager.sharedInstance.browseSearch(text: searchBar.text!)
        refreshControl.endRefreshing()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.pleaseWait()
        SocketIOManager.sharedInstance.browseSearch(text: searchBar.text!)
    }
}
