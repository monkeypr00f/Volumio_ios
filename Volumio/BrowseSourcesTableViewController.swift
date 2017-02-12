//
//  BrowseSourcesTableViewController.swift
//  Volumio
//
//  Created by Federico Sintucci on 01/10/16.
//  Copyright © 2016 Federico Sintucci. All rights reserved.
//

import UIKit

/**
    Controller for browse sources table view. Inherits automatic connection handling from `VolumioTableViewController`.
 */
class BrowseSourcesTableViewController: VolumioTableViewController {

    var sourcesList: [SourceObject] = []

    // MARK: - View Callbacks

    override func viewDidLoad() {
        super.viewDidLoad()

        localize()

        tableView.tableFooterView = UIView(frame: CGRect.zero)

        refreshControl?.addTarget(self,
            action: #selector(handleRefresh),
            for: UIControlEvents.valueChanged
        )
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        registerObserver(forName: .browseSources) { (notification) in
            self.clearAllNotice()

            guard let sources = notification.object as? [SourceObject]
                else { return }
            self.update(sources: sources)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        clearAllNotice()
    }

    // MARK: - View Update

    func update(sources: [SourceObject]? = nil) {
        if let sources = sources {
            sourcesList = sources
        }
        tableView.reloadData()
    }

    // MARK: - Volumio Events

    override func volumioWillConnect() {
        pleaseWait()

        super.volumioWillConnect()
    }

    override func volumioDidConnect() {
        super.volumioDidConnect()

        VolumioIOManager.shared.browseSources()
    }

    override func volumioDidDisconnect() {
        clearAllNotice()

        super.volumioDidDisconnect()

        update(sources: [])
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
            guard let destinationController = segue.destination as? BrowseFolderTableViewController
                else { fatalError() }

            guard let indexPath = self.tableView.indexPathForSelectedRow else { return }

            let item = sourcesList[indexPath.row]

            switch item.pluginType {
            case .some("music_service"):
                destinationController.serviceType = .music_service
            default:
                destinationController.serviceType = .generic
            }
            destinationController.serviceName = item.name
            destinationController.serviceUri = item.uri
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
