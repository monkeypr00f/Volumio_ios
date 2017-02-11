//
//  BrowseFolderTableViewController.swift
//  Volumio
//
//  Created by Federico Sintucci on 24/10/16.
//  Copyright © 2016 Federico Sintucci. All rights reserved.
//

import UIKit

class BrowseFolderTableViewController: UITableViewController,
    ObservesNotifications, ShowsNotices,
    BrowseActionsDelegate, PlaylistActionsDelegate
{
    var serviceType: ServiceType?
    var serviceName: String!
    var serviceUri: String!
    var serviceService: String!

    var browseHeaderView: BrowseActions?
    var playlistHeaderView: PlaylistActions?

    var sourceLibrary: [LibraryObject] = []

    var observers: [AnyObject] = []

    // MARK: - View Callbacks

    override func viewDidLoad() {
        super.viewDidLoad()

        title = serviceName

        refreshControl?.addTarget(self,
            action: #selector(handleRefresh),
            for: UIControlEvents.valueChanged
        )

        // browseHeaderView
        let browseHeaderViewFrame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 56.0)
        browseHeaderView = BrowseActions(frame: browseHeaderViewFrame)
        browseHeaderView?.delegate = self

        // playlistHeaderView
        let playlistHeaderViewFrame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 56.0)
        playlistHeaderView = PlaylistActions(frame: playlistHeaderViewFrame)
        playlistHeaderView?.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        registerObserver(forName: .browseLibrary) { (notification) in
            self.clearAllNotice()

            guard let sources = notification.object as? [LibraryObject]
                else { return }
            self.update(sources: sources)
        }
        registerObserver(forName: .playlistPlaying) { (notification) in
            guard let object = notification.object
                else { return }
            self.notice(playing: object)
        }
        registerObserver(forName: .playlistDeleted) { (notification) in
            guard let object = notification.object
                else { return }
            self.notice(deleted: object, delayed: 0.5)

            VolumioIOManager.shared.browseLibrary(uri: self.serviceUri)
        }
        registerObserver(forName: .addedToQueue) { (notification) in
            guard let object = notification.object
                else { return }
            self.notice(queueAdded: object)
        }
        registerObserver(forName: .addedToPlaylist) { (notification) in
            guard let object = notification.object
                else { return }
            self.notice(playlistAdded: object)
        }
        registerObserver(forName: .removedFromPlaylist) { (notification) in
            guard let object = notification.object
                else { return }
            self.notice(playlistRemoved: object, delayed: 0.5)

            VolumioIOManager.shared.browseLibrary(uri: self.serviceUri)
        }

        pleaseWait()
    }

    override func viewDidAppear(_ animated: Bool) {
        if !VolumioIOManager.shared.isConnected && !VolumioIOManager.shared.isConnecting {
            _ = navigationController?.popToRootViewController(animated: animated)
        } else {
            VolumioIOManager.shared.browseLibrary(uri: serviceUri)
        }
        super.viewDidAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        clearAllNotice()
    }

    override func viewDidDisappear(_ animated: Bool) {
        unregisterObservers()

        super.viewDidDisappear(animated)
    }

    // MARK: - View Update

    func update(sources: [LibraryObject]? = nil) {
        if let sources = sources {
            sourceLibrary = sources
        }
        tableView.reloadData()
    }

    func notice(playing playlist: Any, delayed time: Double? = nil) {
        notice(localizedPlaylistPlaying(name: String(describing: playlist)), delayed: time)
    }

    func notice(deleted playlist: Any, delayed time: Double? = nil) {
        notice(localizedPlaylistDeleted(name: String(describing: playlist)), delayed: time)
    }

    func notice(queueAdded item: Any, delayed time: Double? = nil) {
        notice(localizedAddedItemToQueueNotice(name: String(describing: item)), delayed: time)
    }

    func notice(playlistAdded item: Any, delayed time: Double? = nil) {
        notice(localizedAddedItemToPlaylistNotice(name: String(describing: item)), delayed: time)
    }

    func notice(playlistRemoved item: Any, delayed time: Double? = nil) {
        notice(localizedRemovedItemFromPlaylistNotice(name: String(describing: item)),
            delayed: time
        )
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return sourceLibrary.count
    }

    override func tableView(_ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let item = sourceLibrary[indexPath.row]

        switch item.type {
        case .title:
            return self.tableView(tableView, cellForTitle: item, forRowAt: indexPath)
        case _ where item.type.isTrack:
            return self.tableView(tableView, cellForTrack: item, forRowAt: indexPath)
        case _ where item.type.isSong:
            return self.tableView(tableView, cellForTrack: item, forRowAt: indexPath)
        case _ where item.type.isRadio:
            return self.tableView(tableView, cellForRadio: item, forRowAt: indexPath)
        default:
            return self.tableView(tableView, cellForFolder: item, forRowAt: indexPath)
        }
    }

    func tableView(_ tableView: UITableView,
        cellForTitle item: Item,
        forRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "title", for: indexPath)

        cell.textLabel?.text = item.localizedTitle
        return cell
    }

    func tableView(_ tableView: UITableView,
        cellForTrack item: Item,
        forRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let reuseableCell = tableView.dequeueReusableCell(withIdentifier: "track", for: indexPath)
        guard let cell = reuseableCell as? TrackTableViewCell
            else { fatalError() }

        cell.trackTitle.text = item.localizedTitle
        cell.trackArtist.text = item.localizedArtistAndAlbum
        cell.trackImage.setAlbumArt(for: item)
        return cell
    }

    func tableView(_ tableView: UITableView,
        cellForRadio item: Item,
        forRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let reuseableCell = tableView.dequeueReusableCell(withIdentifier: "radio", for: indexPath)
        guard let cell = reuseableCell as? RadioTableViewCell
            else { fatalError() }

        cell.radioTitle.text = item.localizedTitle
        cell.radioImage.setAlbumArt(for: item)
        return cell
    }

    func tableView(_ tableView: UITableView,
        cellForFolder item: Item,
        forRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let reuseableCell = tableView.dequeueReusableCell(withIdentifier: "folder", for: indexPath)
        guard let cell = reuseableCell as? FolderTableViewCell
            else { fatalError() }

        cell.folderTitle.text = item.localizedTitle
        cell.folderImage.setAlbumArt(for: item)
        return cell
    }

    override func tableView(_ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        return 54.0
    }

    override func tableView(_ tableView: UITableView,
        commit editingStyle: UITableViewCellEditingStyle,
        forRowAt indexPath: IndexPath
    ) {
        if editingStyle == .delete {
            let track = sourceLibrary[indexPath.row]

            guard let uri = track.uri, let service = track.service else { return }

            VolumioIOManager.shared.removeFromPlaylist(
                name: serviceName,
                uri: uri,
                service: service
            )
        }
    }

    override func tableView(_ tableView: UITableView,
        canEditRowAt indexPath: IndexPath
    ) -> Bool {
        let type = sourceLibrary[indexPath.row].type
        return type == .song || serviceType == .playlist
    }

    override func tableView(_ tableView: UITableView,
        viewForHeaderInSection section: Int
    ) -> UIView? {
        switch serviceType {
        case .some(.folder):
            return browseHeaderView
        case .some(.playlist):
            return playlistHeaderView
        default:
            return nil
        }
    }

    override func tableView(_ tableView: UITableView,
        heightForHeaderInSection section: Int
    ) -> CGFloat {
        switch serviceType {
        case .some(.folder),
             .some(.playlist):
            return 56.0
        default:
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let type = sourceLibrary[indexPath.row].type
        if type == .song || type.isRadio {
            let item = self.sourceLibrary[indexPath.row]
            songActions(uri: item.uri!, title: item.title!, service: item.service!)
        }
    }

    func songActions(uri: String, title: String, service: String) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: localizedAddAndPlayTitle, style: .default) { (_) in
            VolumioIOManager.shared.addAndPlay(uri: uri, title: title, service: service)
        })
        alert.addAction(UIAlertAction(title: localizedAddToQueueTitle, style: .default) { (_) in
            VolumioIOManager.shared.addToQueue(uri: uri, title: title, service: service)
        })
        alert.addAction(UIAlertAction(title: localizedClearAndPlayTitle, style: .default) { (_) in
            VolumioIOManager.shared.clearAndPlay(uri: uri, title: title, service: service)
        })
        alert.addAction(UIAlertAction(title: localizedCancelTitle, style: .cancel))

        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }

    func handleRefresh(refreshControl: UIRefreshControl) {
        VolumioIOManager.shared.browseLibrary(uri: serviceUri)
        refreshControl.endRefreshing()
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueFolder" {
            guard let indexPath = self.tableView.indexPathForSelectedRow else { return }

            let item = sourceLibrary[indexPath.row] as LibraryObject

            if let destinationController = segue.destination as? BrowseFolderTableViewController {
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

// MARK: - BrowseActionsDelegate

extension BrowseFolderTableViewController {

    func browseAddAndPlay() {
        VolumioIOManager.shared.addAndPlay(
            uri: serviceUri,
            title: serviceName,
            service: serviceService
        )
    }

    func browseAddToQueue() {
        VolumioIOManager.shared.addToQueue(
            uri: serviceUri,
            title: serviceName,
            service: serviceService
        )
    }

    func browseClearAndPlay() {
        // FIXME: this will fail for "last 100" playlist, because serviceService is nil
        VolumioIOManager.shared.clearAndPlay(
            uri: serviceUri,
            title: serviceName,
            service: serviceService
        )
    }

}

// MARK: - PlaylistActionsDelegate

extension BrowseFolderTableViewController {

    func playlistAddAndPlay() {
        if serviceService == "mpd" {
            VolumioIOManager.shared.playPlaylist(name: serviceName)
        } else {
            VolumioIOManager.shared.addAndPlay(
                uri: serviceUri,
                title: serviceName,
                service: serviceService
            )
        }
    }

    func playlistEdit() {
        self.isEditing = !self.isEditing
    }

}

// MARK: - Localization

extension BrowseFolderTableViewController {

    fileprivate var localizedCancelTitle: String {
        return NSLocalizedString("CANCEL", comment: "[trigger] cancel action")
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

    fileprivate func localizedPlaylistPlaying(name: String) -> String {
        return String.localizedStringWithFormat(
            localizedPlaylistPlaying,
            name
        )
    }
    fileprivate var localizedPlaylistPlaying: String {
        return NSLocalizedString("PLAYLIST_PLAYING",
            comment: "[hint](format) started playing playlist(%@)"
        )
    }

    fileprivate func localizedPlaylistDeleted(name: String) -> String {
        return String.localizedStringWithFormat(
            localizedPlaylistDeleted,
            name
        )
    }
    fileprivate var localizedPlaylistDeleted: String {
        return NSLocalizedString("PLAYLIST_DELETED",
            comment: "[hint](format) deleted playlist(%@)"
        )
    }

    fileprivate func localizedAddedItemToQueueNotice(name: String) -> String {
        return String.localizedStringWithFormat(
            localizedAddedItemToQueueNotice,
            name
        )
    }
    fileprivate var localizedAddedItemToQueueNotice: String {
        return NSLocalizedString("QUEUE_ADDED_ITEM",
            comment: "[hint](format) added item(%@) to queue"
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

    fileprivate func localizedRemovedItemFromPlaylistNotice(name: String) -> String {
        return String.localizedStringWithFormat(
            localizedRemovedItemFromPlaylistNotice,
            name
        )
    }
    fileprivate var localizedRemovedItemFromPlaylistNotice: String {
        return NSLocalizedString("PLAYLIST_REMOVED_ITEM",
            comment: "[hint](format) removed item(%@) from playlist"
        )
    }

}
