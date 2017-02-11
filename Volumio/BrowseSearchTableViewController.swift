//
//  BrowseSearchTableViewController.swift
//  Volumio
//
//  Created by Federico Sintucci on 22/10/16.
//  Copyright © 2016 Federico Sintucci. All rights reserved.
//

import UIKit

class BrowseSearchTableViewController: UITableViewController, UISearchBarDelegate,
    ObservesNotifications, ShowsNotices
{

    @IBOutlet weak private var searchBar: UISearchBar!

    var sourcesList: [SearchResultObject] = []

    var observers: [AnyObject] = []

    // MARK: - View Callbacks

    override func viewDidLoad() {
        super.viewDidLoad()

        localize()

        tableView.tableFooterView = UIView(frame: CGRect.zero)

        searchBar.delegate = self

        refreshControl?.addTarget(self,
            action: #selector(handleRefresh),
            for: UIControlEvents.valueChanged
        )
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        registerObserver(forName: .browseSearch) { (notification) in
            self.clearAllNotice()

            guard let sources = notification.object as? [SearchResultObject]
                else { return }
            self.update(sources: sources)
        }
        registerObserver(forName: .addedToPlaylist) { (notification) in
            guard let object = notification.object
                else { return }
            self.notice(playlistAdded: object)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        if !VolumioIOManager.shared.isConnected && !VolumioIOManager.shared.isConnecting {
            _ = navigationController?.popToRootViewController(animated: animated)
        }

        super.viewDidAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        clearAllNotice()

        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - View Updates

    func update(sources: [SearchResultObject]? = nil) {
        if let sources = sources {
            sourcesList = sources
        }
        tableView.reloadData()
    }

    func notice(playlistAdded item: Any, delayed time: Double? = nil) {
        notice(localizedAddedItemToPlaylistNotice(name: String(describing: item)), delayed: time)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sourcesList.count
    }

    override func tableView(_ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        let sections = sourcesList[section]
        if let items = sections.items {
            return items.count
        }
        return 0
    }

    override func tableView(_ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        let itemList = sourcesList[indexPath.section]
        let item = itemList.items![indexPath.row] as LibraryObject

        if item.type == .song || item.type == .track {
            let anyCell = tableView.dequeueReusableCell(withIdentifier: "track", for: indexPath)
            guard let cell = anyCell as? TrackTableViewCell
                else { fatalError() }

            cell.trackTitle.text = item.localizedTitle
            cell.trackArtist.text = item.localizedArtistAndAlbum
            cell.trackImage.setAlbumArt(for: item)
            return cell

        } else if item.type.isRadio {
            let anyCell = tableView.dequeueReusableCell(withIdentifier: "radio", for: indexPath)
            guard let cell = anyCell as? RadioTableViewCell
                else { fatalError() }

            cell.radioTitle.text = item.localizedTitle
            cell.radioImage.setAlbumArt(for: item)
            return cell

        } else {
            let anyCell = tableView.dequeueReusableCell(withIdentifier: "folder", for: indexPath)
            guard let cell = anyCell as? FolderTableViewCell
                else { fatalError() }

            cell.folderTitle.text = item.localizedTitle
            cell.folderImage.setAlbumArt(for: item)
            return cell

        }
    }

    override func tableView(_ tableView: UITableView,
        titleForHeaderInSection section: Int
    ) -> String? {
        return sourcesList[section].title
    }

    override func tableView(_ tableView: UITableView,
        commit editingStyle: UITableViewCellEditingStyle,
        forRowAt indexPath: IndexPath
    ) {
    }

    override func tableView(_ tableView: UITableView,
        editActionsForRowAt indexPath: IndexPath
    ) -> [UITableViewRowAction]? {

        let itemList = sourcesList[indexPath.section]
        let item = itemList.items![indexPath.row] as LibraryObject

        let play = UITableViewRowAction(style: .normal, title: localizedPlayTitle) { _ in
            guard let uri = item.uri, let title = item.title, let service = item.service
                else { return }
            VolumioIOManager.shared.addAndPlay(uri: uri, title: title, service: service)
            tableView.setEditing(false, animated: true)
        }
        play.backgroundColor = UIColor.playButtonBackground

        let more = UITableViewRowAction(style: .normal, title: localizedMoreTitle) { _ in
            self.playlistActions(item: item)
            tableView.setEditing(false, animated: true)
        }
        more.backgroundColor = UIColor.moreButtonBackground

        return [more, play]
    }

    override func tableView(_ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        return 54.0
    }

    func handleRefresh(refreshControl: UIRefreshControl) {
        if let text = searchBar.text {
            VolumioIOManager.shared.browseSearch(text: text)
        }
        refreshControl.endRefreshing()
    }

    func playlistActions(item: LibraryObject) {
        guard let itemUri = item.uri,
              let itemTitle = item.title,
              let itemService = item.service
            else { return }

        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        alert.addAction(
            UIAlertAction(title: localizedPlayTitle, style: .default) { _ in
                    VolumioIOManager.shared.addAndPlay(
                        uri: itemUri,
                        title: itemTitle,
                        service: itemService
                    )
            })
        alert.addAction(
            UIAlertAction(title: localizedAddToQueueTitle, style: .default) { _ in
                    VolumioIOManager.shared.addToQueue(
                        uri: itemUri,
                        title: itemTitle,
                        service: itemService
                    )
            })
        alert.addAction(
            UIAlertAction(title: localizedClearAndPlayTitle, style: .default) { _ in
                    VolumioIOManager.shared.clearAndPlay(
                        uri: itemUri,
                        title: itemTitle,
                        service: itemService
                    )
            })
        alert.addAction(UIAlertAction(title: localizedCancelTitle, style: .cancel))

        present(alert, animated: true, completion: nil)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.pleaseWait()
        VolumioIOManager.shared.browseSearch(text: searchBar.text!)
        searchBar.resignFirstResponder()
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "browseFolder" {
            guard let destinationController = segue.destination as? BrowseFolderTableViewController
                else { fatalError() }

            guard let indexPath = tableView.indexPathForSelectedRow else { return }

            let itemList = sourcesList[indexPath.section]
            let items = itemList.items
            if let items = items {
                let item = items[indexPath.row] as LibraryObject

                switch item.type {
                case .folder:
                    destinationController.serviceType = .folder
                case .playlist:
                    destinationController.serviceType = .playlist
                default:
                    destinationController.serviceType = .generic
                }
                destinationController.serviceName = item.title
                destinationController.serviceUri = item.uri
                destinationController.serviceService = item.service
            }
        }
    }
}

// MARK: - Localization

extension BrowseSearchTableViewController {

    fileprivate func localize() {
        navigationItem.title = NSLocalizedString("BROWSE_SEARCH",
            comment: "browse search view title"
        )
    }

    fileprivate var localizedMoreTitle: String {
        return NSLocalizedString("MORE", comment: "[trigger] more actions")
    }

    fileprivate var localizedCancelTitle: String {
        return NSLocalizedString("CANCEL", comment: "[trigger] cancel action")
    }

    fileprivate var localizedPlayTitle: String {
        return NSLocalizedString("PLAY", comment: "[trigger] play anything")
    }

    fileprivate var localizedAddAndPlayTitle: String {
        return NSLocalizedString("BROWSE_ADD_TO_QUEUE_AND_PLAY",
            comment: "[trigger] add item to queue and start playing"
        )
    }

    fileprivate var localizedAddToQueueTitle: String {
        return NSLocalizedString("BROWSE_ADD_TO_QUEUE",
            comment: "[trigger] add item to queue"
        )
    }

    fileprivate var localizedClearAndPlayTitle: String {
        return NSLocalizedString("BROWSE_CLEAR_AND_ADD_TO_QUEUE_AND_PLAY",
            comment: "[trigger] clear queue, add item and start playing"
        )
    }

    fileprivate func localizedAddedItemToPlaylistNotice(name: String) -> String {
        return String.localizedStringWithFormat(
            localizedAddedItemToPlaylistNotice,
            name
        )
    }

    fileprivate var localizedAddedItemToPlaylistNotice: String {
        return NSLocalizedString("PLAYLIST_ADDED_ITEM",
            comment: "[hint](format) added item(%@) to playlist"
        )
    }

}
