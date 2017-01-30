//
//  BrowseFolderTableViewController.swift
//  Volumio
//
//  Created by Federico Sintucci on 24/10/16.
//  Copyright © 2016 Federico Sintucci. All rights reserved.
//

import UIKit

class BrowseFolderTableViewController: UITableViewController,
    BrowseActionsDelegate, PlaylistActionsDelegate
{
    
    var serviceType : ServiceType!
    var serviceName : String!
    var serviceUri : String!
    var serviceService : String!
    
    var browseHeaderView: BrowseActions?
    var playlistHeaderView: PlaylistActions?
    var sourceLibrary : [LibraryObject] = []
    
    var sourceLibrarySections = [LibraryObject]()
    var sourceLibraryDict = [String: [String]]()
    
//    func generateLibraryDict() {
//        for source in sourceLibrary {
//            let key = "\(source[(source.title?.startIndex)!])"
//            if var sourceValues = sourceLibraryDict[key] {
//                sourceValue
//            }
//        }
//    }

    // MARK: - View Callbacks
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = serviceName
        
        pleaseWait()
        
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
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
        VolumioIOManager.shared.browseLibrary(uri: serviceUri)

        registerObservers()

        super.viewWillAppear(animated)
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
    
    private func registerObservers() {
        NotificationCenter.default.addObserver(self,
            selector: #selector(updateSourceLibrary(notification:)),
            name: .browseLibrary,
            object: nil
        )
        NotificationCenter.default.addObserver(self,
            selector: #selector(playPlaylist(notification:)),
            name: .playlistPlaying,
            object: nil
        )
        NotificationCenter.default.addObserver(self,
            selector: #selector(deletePlaylist(notification:)),
            name: .playlistDeleted,
            object: nil
        )
        NotificationCenter.default.addObserver(self,
            selector: #selector(addToQueue(notification:)),
            name: .addedToQueue,
            object: nil
        )
        NotificationCenter.default.addObserver(self,
            selector: #selector(addToPlaylist(notification:)),
            name: .addedToPlaylist,
            object: nil
        )
        NotificationCenter.default.addObserver(self,
            selector: #selector(removeFromPlaylist(notification:)),
            name: .removedFromPlaylist,
            object: nil
        )
    }
    
    func updateSourceLibrary(notification: NSNotification) {
        guard let sources = notification.object as? [LibraryObject] else { return }
        
        sourceLibrary = sources
        tableView.reloadData()
        clearAllNotice()
    }
    
    func playPlaylist(notification: NSNotification) {
        guard let object = notification.object else { return }

        noticeTop(
            localizedPlaylistPlaying(name: String(describing: object)),
            autoClear: true,
            autoClearTime: 3
        )
    }
    
    func deletePlaylist(notification: NSNotification) {
        guard let object = notification.object else { return }
        
        VolumioIOManager.shared.browseLibrary(uri: self.serviceUri)
        
        let waitTime = DispatchTime.now() + .milliseconds(500)
        DispatchQueue.main.asyncAfter(deadline: waitTime, execute: {
            self.noticeTop(
                self.localizedPlaylistDeleted(name: String(describing: object)),
                autoClear: true,
                autoClearTime: 3
            )
        })
    }
    
    func addToQueue(notification: NSNotification) {
        guard let object = notification.object else { return }

        noticeTop(
            localizedAddedItemToQueueNotice(name: String(describing: object)),
            autoClear: true,
            autoClearTime: 3
        )
    }
    
    func addToPlaylist(notification: NSNotification) {
        guard let object = notification.object else { return }
        
        noticeTop(
            localizedAddedItemToPlaylistNotice(name: String(describing: object)),
            autoClear: true,
            autoClearTime: 3
        )
    }
    
    func removeFromPlaylist(notification: NSNotification) {
        guard let object = notification.object else { return }
        
        VolumioIOManager.shared.browseLibrary(uri: self.serviceUri)
        
        let waitTime = DispatchTime.now() + .milliseconds(500)
        DispatchQueue.main.asyncAfter(deadline: waitTime, execute: {
            self.noticeTop(
                self.localizedRemovedItemFromPlaylistNotice(name: String(describing: object)),
                autoClear: true,
                autoClearTime: 3
            )
        })
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
        if sourceLibrary[indexPath.row].type == .song {
            let cell = tableView.dequeueReusableCell(withIdentifier: "track", for: indexPath) as! TrackTableViewCell
            let track = sourceLibrary[indexPath.row]
            
            cell.trackTitle.text = track.localizedTitle
            cell.trackArtist.text = track.localizedArtistAndAlbum
            
            cell.trackImage.image = nil // TODO: quickfix for cell reuse
            
            if track.albumArt?.range(of:"http") != nil{
                cell.trackImage.contentMode = .scaleAspectFill
                cell.trackImage.kf.setImage(with: URL(string: track.albumArt!), placeholder: UIImage(named: "background"), options: [.transition(.fade(0.2))])
            } else {
                // FIXME: this will fail for songs without artist or album field
                LastFMService.shared.albumGetImageURL(artist: track.artist!, album: track.album!, completion: { (albumUrl) in
                    if let albumUrl = albumUrl {
                        DispatchQueue.main.async {
                            cell.trackImage.contentMode = .scaleAspectFill
                            cell.trackImage.kf.setImage(with: albumUrl, placeholder: UIImage(named: "background"), options: [.transition(.fade(0.2))])
                        }
                    }
                })
            }
            return cell
         
        } else if sourceLibrary[indexPath.row].type.isRadio {
            let cell = tableView.dequeueReusableCell(withIdentifier: "radio", for: indexPath) as! FolderTableViewCell
            let folder = sourceLibrary[indexPath.row]
            
            cell.folderTitle.text = folder.title ?? ""
            if folder.albumArt?.range(of:"http") != nil{
                cell.folderImage.contentMode = .scaleAspectFill
                cell.folderImage.kf.setImage(with: URL(string: folder.albumArt!), placeholder: UIImage(named: "radio"), options: [.transition(.fade(0.2))])
            } else {
                cell.folderImage.contentMode = .center
                cell.folderImage.image = UIImage(named: "radio")
            }
            return cell
            
        } else if sourceLibrary[indexPath.row].type == .title {
            let cell = tableView.dequeueReusableCell(withIdentifier: "title", for: indexPath)
            let folder = sourceLibrary[indexPath.row]
            
            cell.textLabel?.text = folder.title

            return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "folder", for: indexPath) as! FolderTableViewCell
            let folder = sourceLibrary[indexPath.row]
            
            cell.folderTitle.text = folder.title ?? ""
            if folder.albumArt?.range(of:"http") != nil{
                cell.folderImage.contentMode = .scaleAspectFill
                cell.folderImage.kf.setImage(with: URL(string: folder.albumArt!), placeholder: UIImage(named: "folder"), options: [.transition(.fade(0.2))])
            } else {
                cell.folderImage.contentMode = .center
                cell.folderImage.image = UIImage(named: "folder")
            }
            return cell
        }
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
        if serviceType == .folder {
            return browseHeaderView
        } else if serviceType == .playlist {
            return playlistHeaderView
        } else {
            let emptyView = UIView()
            return emptyView
        }
    }

    override func tableView(_ tableView: UITableView,
        heightForHeaderInSection section: Int
    ) -> CGFloat {
        if serviceType == .folder || serviceType == .playlist {
            return 56.0
        } else {
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
        alert.addAction(UIAlertAction(title: localizedAddAndPlayTitle, style: .default) {
            (action) in
                VolumioIOManager.shared.addAndPlay(uri: uri, title: title, service: service)
        })
        alert.addAction(UIAlertAction(title: localizedAddToQueueTitle, style: .default) {
            (action) in
                VolumioIOManager.shared.addToQueue(uri: uri, title: title, service: service)
        })
        alert.addAction(UIAlertAction(title: localizedClearAndPlayTitle, style: .default) {
            (action) in
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
    
    // MARK: - BrowseActionsDelegate
    
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
    
    // MARK: - PlaylistActionsDelegate
    
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
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueFolder" {
            guard let indexPath = self.tableView.indexPathForSelectedRow else { return }
            
            let item = sourceLibrary[indexPath.row] as LibraryObject

            let destinationController = segue.destination as! BrowseFolderTableViewController

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
