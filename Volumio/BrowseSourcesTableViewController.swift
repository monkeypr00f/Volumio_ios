//
//  BrowseSourcesTableViewController.swift
//  Volumio
//
//  Created by Federico Sintucci on 01/10/16.
//  Copyright © 2016 Federico Sintucci. All rights reserved.
//

import UIKit

class BrowseSourcesTableViewController: UITableViewController {
    
    var sourcesList : [SourceObject] = []
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        VolumioIOManager.shared.browseSources()
        registerObservers()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        localize()

        pleaseWait()
        
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
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
            name: .browseSources,
            object: nil
        )
    }
    
    func updateSources(notification: NSNotification) {
        guard let sources = notification.object as? [SourceObject] else { return }
        
        sourcesList = sources
        tableView.reloadData()
        clearAllNotice()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return sourcesList.count
    }

    override func tableView(_ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "source", for: indexPath)
        let source = sourcesList[indexPath.row]
        
        cell.textLabel?.text = source.name
        return cell
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        VolumioIOManager.shared.browseSources()
        refreshControl.endRefreshing()
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showFolder" {
            guard let indexPath = self.tableView.indexPathForSelectedRow else { return }
            
            let destinationController = segue.destination as! BrowseFolderTableViewController
            destinationController.serviceName = sourcesList[indexPath.row].name
            destinationController.serviceUri = sourcesList[indexPath.row].uri
            destinationController.serviceType = sourcesList[indexPath.row].plugin_type
        }
    }

}

// MARK: - Localization

extension BrowseSourcesTableViewController {
    
    fileprivate func localize() {
        navigationItem.title = NSLocalizedString("BROWSE",
            comment: "browse sources view title"
        )
    }
    
}
