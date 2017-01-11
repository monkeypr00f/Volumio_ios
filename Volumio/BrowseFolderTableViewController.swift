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
    
    var serviceName : String!
    var serviceUri : String!
    var serviceType : String!
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
	
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        SocketIOManager.sharedInstance.browseLibrary(uri: serviceUri)
        registerObservers()
    }
    
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
        NotificationCenter.default.addObserver(self,
            selector: #selector(playPlaylist(notification:)),
            name: .playlistPlaying,
            object: nil
        )
    }
    
    func updateSourceLibrary(notification: NSNotification) {
        guard let sources = notification.object as? [LibraryObject] else { return }
        
        sourceLibrary = sources
        tableView.reloadData()
        clearAllNotice()
    }
    
    func deletePlaylist(notification: NSNotification) {
        guard let object = notification.object else { return }
        
        SocketIOManager.sharedInstance.browseLibrary(uri: serviceUri)
        
        let waitTime = DispatchTime.now() + .milliseconds(500)
        DispatchQueue.main.asyncAfter(deadline: waitTime, execute: {
            self.noticeTop("\(object) playlist removed", autoClear: true, autoClearTime: 3)
        })
    }
    
    func playPlaylist(notification: NSNotification) {
        guard let object = notification.object else { return }

        noticeTop("\(object) playing", autoClear: true, autoClearTime: 3)
    }
    
    func addToQueue(notification: NSNotification) {
        guard let object = notification.object else { return }

        noticeTop("\(object) added to queue", autoClear: true, autoClearTime: 3)
    }
    
    func addToPlaylist(notification: NSNotification) {
        guard let object = notification.object else { return }
        
        noticeTop("Added to \(object)", autoClear: true, autoClearTime: 3)
    }
    
    func removeFromPlaylist(notification: NSNotification) {
        guard let object = notification.object else { return }
        
        SocketIOManager.sharedInstance.browseLibrary(uri: serviceUri)
        
        let waitTime = DispatchTime.now() + .milliseconds(500)
        DispatchQueue.main.asyncAfter(deadline: waitTime, execute: {
            self.noticeTop("Removed from \(object)", autoClear: true, autoClearTime: 3)
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
        if sourceLibrary[indexPath.row].type == "song" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "track", for: indexPath) as! TrackTableViewCell
            let track = sourceLibrary[indexPath.row]
            
            cell.trackTitle.text = track.title ?? ""
            let artist = track.artist ?? ""
            let album = track.album ?? ""
            cell.trackArtist.text = "\(artist) - \(album)"
            
            if track.albumArt?.range(of:"http") != nil{
                cell.trackImage.contentMode = .scaleAspectFill
                cell.trackImage.kf.setImage(with: URL(string: track.albumArt!), placeholder: UIImage(named: "background"), options: [.transition(.fade(0.2))])
            } else {
                LastFmManager.sharedInstance.getAlbumArt(artist: track.artist!, album: track.album!, completionHandler: { (albumUrl) in
                    if let albumUrl = albumUrl {
                        DispatchQueue.main.async {
                            cell.trackImage.contentMode = .scaleAspectFill
                            cell.trackImage.kf.setImage(with: URL(string: albumUrl), placeholder: UIImage(named: "background"), options: [.transition(.fade(0.2))])
                        }
                    }
                })
            }
            return cell
         
        } else if sourceLibrary[indexPath.row].type == "mywebradio" || sourceLibrary[indexPath.row].type == "webradio" {
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
            
        } else if sourceLibrary[indexPath.row].type == "title" {
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

            SocketIOManager.sharedInstance.removeFromPlaylist(
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
        return type == "song" || serviceType == "playlist"
    }
    
    override func tableView(_ tableView: UITableView,
        viewForHeaderInSection section: Int
    ) -> UIView? {
        if serviceType == "folder" {
            return browseHeaderView
        } else if serviceType == "playlist" {
            return playlistHeaderView
        } else {
            let emptyView = UIView()
            return emptyView
        }
    }

    override func tableView(_ tableView: UITableView,
        heightForHeaderInSection section: Int
    ) -> CGFloat {
        if serviceType == "folder" || serviceType == "playlist" {
            return 56.0
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let type = sourceLibrary[indexPath.row].type
        if type == "song" || type == "mywebradio" || type == "webradio" {
            let item = self.sourceLibrary[indexPath.row]
            songActions(uri: item.uri!, title: item.title!, service: item.service!)
        }
    }
    
    func songActions(uri: String, title: String, service: String) {
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: localizedAddAndPlayTitle, style: .default) {
            (action) in
                SocketIOManager.sharedInstance.addAndPlay(
                    uri: uri,
                    title: title,
                    service: service
                )
        })
        alert.addAction(UIAlertAction(title: localizedAddToQueueTitle, style: .default) {
            (action) in
                SocketIOManager.sharedInstance.addToQueue(
                    uri: uri,
                    title: title,
                    service: service
                )
        })
        alert.addAction(UIAlertAction(title: localizedClearAndPlayTitle, style: .default) {
            (action) in
                SocketIOManager.sharedInstance.clearAndPlay(
                    uri: uri,
                    title: title,
                    service: service
                )
        })
        alert.addAction(UIAlertAction(title: localizedCancelTitle, style: .cancel))
        
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        SocketIOManager.sharedInstance.browseLibrary(uri: serviceUri)
        refreshControl.endRefreshing()
    }
    
    // MARK: - BrowseActionsDelegate
    
    func browseAddAndPlay() {
        SocketIOManager.sharedInstance.addAndPlay(
            uri: serviceUri,
            title: serviceName,
            service: serviceService
        )
    }
    
    func browseAddToQueue() {
        SocketIOManager.sharedInstance.addToQueue(
            uri: serviceUri,
            title: serviceName,
            service: serviceService
        )
    }
    
    func browseClearAndPlay() {
        SocketIOManager.sharedInstance.clearAndPlay(
            uri: serviceUri,
            title: serviceName,
            service: serviceService
        )
    }
    
    // MARK: - PlaylistActionsDelegate
    
    func playlistAddAndPlay() {
        if serviceService == "mpd" {
            SocketIOManager.sharedInstance.playPlaylist(name: serviceName)
        } else {
            SocketIOManager.sharedInstance.addAndPlay(
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
            
            let destinationController = segue.destination as! BrowseFolderTableViewController
            destinationController.serviceName = sourceLibrary[indexPath.row].title
            destinationController.serviceUri = sourceLibrary[indexPath.row].uri
            destinationController.serviceType = sourceLibrary[indexPath.row].type
            destinationController.serviceService = sourceLibrary[indexPath.row].service
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
    
}
