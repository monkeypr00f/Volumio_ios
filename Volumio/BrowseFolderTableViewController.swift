//
//  BrowseFolderTableViewController.swift
//  Volumio
//
//  Created by Federico Sintucci on 24/10/16.
//  Copyright © 2016 Federico Sintucci. All rights reserved.
//

import UIKit

class BrowseFolderTableViewController: UITableViewController, BrowseActionsDelegate, PlaylistActionsDelegate {
    
    var serviceName : String!
    var serviceUri : String!
    var serviceType : String!
    var serviceService : String!
    
    var browseHeaderView: BrowseActions?
    var playlistHeaderView: PlaylistActions?
    var sourceLibrary : [LibraryObject] = []
    
    var sourceLibrarySections = [LibraryObject]()
    var sourceLibraryDict = [String: [String]]()
    
    func generateLibraryDict() {
        for source in sourceLibrary {
            let key = "\(source[(source.title?.startIndex)!])"
            if var sourceValues = sourceLibraryDict[key] {
                sourceValue
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        SocketIOManager.sharedInstance.browseLibrary(uri: serviceUri)
        registerObservers()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = serviceName
        self.pleaseWait()
        
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        self.refreshControl?.addTarget(self, action: #selector(handleRefresh), for: UIControlEvents.valueChanged)
        
        // browseHeaderView
        let browseHeaderViewFrame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 56.0)
        browseHeaderView = BrowseActions(frame: browseHeaderViewFrame)
        browseHeaderView?.delegate = self
        
        // playlistHeaderView
        let playlistHeaderViewFrame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 56.0)
        playlistHeaderView = PlaylistActions(frame: playlistHeaderViewFrame)
        playlistHeaderView?.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.clearAllNotice()
        NotificationCenter.default.removeObserver(self)
    }
    
    private func registerObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateSourceLibrary(notification:)), name: NSNotification.Name("browseLibrary"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(deletePlaylist(notification:)), name: NSNotification.Name("playlistDeleted"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(addToQueue(notification:)), name: NSNotification.Name("addedToQueue"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(addToPlaylist(notification:)), name: NSNotification.Name("addedToPlaylist"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(removeFromPlaylist(notification:)), name: NSNotification.Name("removedFromPlaylist"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(playPlaylist(notification:)), name: NSNotification.Name("playlistPlaying"), object: nil)
    }
    
    func updateSourceLibrary(notification: NSNotification) {
        if let sources = notification.object as? [LibraryObject] {
            self.sourceLibrary = sources
            self.tableView.reloadData()
            self.clearAllNotice()
        }
    }
    
    func deletePlaylist(notification: NSNotification) {
        SocketIOManager.sharedInstance.browseLibrary(uri: self.serviceUri)
        let waitTime = DispatchTime.now() + .milliseconds(500)
        DispatchQueue.main.asyncAfter(deadline: waitTime, execute: {
            if let notificationObject = notification.object {
                self.noticeTop("\(notificationObject) playlist removed", autoClear: true, autoClearTime: 3)
            }
        })
    }
    
    func playPlaylist(notification: NSNotification) {
        if let notificationObject = notification.object {
            self.noticeTop("\(notificationObject) playing", autoClear: true, autoClearTime: 3)
        }
    }
    
    func addToQueue(notification: NSNotification) {
        if let notificationObject = notification.object {
            self.noticeTop("\(notificationObject) added to queue", autoClear: true, autoClearTime: 3)
        }
    }
    
    func addToPlaylist(notification: NSNotification) {
        if let notificationObject = notification.object {
            self.noticeTop("Added to \(notificationObject)", autoClear: true, autoClearTime: 3)
        }
    }
    
    func removeFromPlaylist(notification: NSNotification) {
        SocketIOManager.sharedInstance.browseLibrary(uri: self.serviceUri)
        let waitTime = DispatchTime.now() + .milliseconds(500)
        DispatchQueue.main.asyncAfter(deadline: waitTime, execute: {
            if let notificationObject = notification.object {
                self.noticeTop("Removed from \(notificationObject)", autoClear: true, autoClearTime: 3)
            }
        })
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sourceLibrary.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
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
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 54.0
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let track = sourceLibrary[indexPath.row]
            SocketIOManager.sharedInstance.removeFromPlaylist(name: serviceName, uri: track.uri!, service: track.service!)
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let type = sourceLibrary[indexPath.row].type
        if type == "song" || serviceType == "playlist" {
            return true
        } else{
            return false
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if serviceType == "folder" {
            return browseHeaderView
        } else if serviceType == "playlist" {
            return playlistHeaderView
        }else {
            let emptyView = UIView()
            return emptyView
        }
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
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
            self.songActions(uri: item.uri!, title: item.title!, service: item.service!)
        }
    }
    
    func songActions(uri:String, title:String, service: String) {
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        let playAction = UIAlertAction(title: "Play", style: .default) { (action) in
            SocketIOManager.sharedInstance.addAndPlay(uri: uri, title: title, service: service)
        }
        alert.addAction(playAction)
        let addToQueue = UIAlertAction(title: "Add to queue", style: .default) { (action) in
            SocketIOManager.sharedInstance.addToQueue(uri: uri, title: title, service: service)
        }
        alert.addAction(addToQueue)
        let clearAndPlay = UIAlertAction(title: "Clear and Play", style: .default) { (action) in
            SocketIOManager.sharedInstance.clearAndPlay(uri: uri, title: title, service: service)
        }
        alert.addAction(clearAndPlay)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(cancel)
        
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
        SocketIOManager.sharedInstance.addAndPlay(uri: self.serviceUri, title: self.serviceName, service: self.serviceService)
    }
    
    func browseAddToQueue() {
        SocketIOManager.sharedInstance.addToQueue(uri: self.serviceUri, title: self.serviceName, service: self.serviceService)
    }
    
    func browseClearAndPlay() {
        SocketIOManager.sharedInstance.clearAndPlay(uri: self.serviceUri, title: self.serviceName, service: self.serviceService)
    }
    
    // MARK: - PlaylistActionsDelegate
    
    func playlistAddAndPlay() {
        if serviceService == "mpd" {
            SocketIOManager.sharedInstance.playPlaylist(name: self.serviceName)
        } else {
            SocketIOManager.sharedInstance.addAndPlay(uri: self.serviceUri, title: self.serviceName, service: self.serviceService)
        }
    }
    
    func playlistEdit() {
        self.isEditing = !self.isEditing
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "segueFolder" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let destinationController = segue.destination as! BrowseFolderTableViewController
                destinationController.serviceName = sourceLibrary[indexPath.row].title
                destinationController.serviceUri = sourceLibrary[indexPath.row].uri
                destinationController.serviceType = sourceLibrary[indexPath.row].type
                destinationController.serviceService = sourceLibrary[indexPath.row].service
            }
        }
    }
}
