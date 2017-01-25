//
//  BrowseSearchTableViewController.swift
//  Volumio
//
//  Created by Federico Sintucci on 22/10/16.
//  Copyright © 2016 Federico Sintucci. All rights reserved.
//

import UIKit

class BrowseSearchTableViewController: UITableViewController, UISearchBarDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    
    var sourcesList : [SearchResultObject] = []
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerObservers()
    }
    
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        clearAllNotice()
        
        NotificationCenter.default.removeObserver(self)
    }

    private func registerObservers() {
        NotificationCenter.default.addObserver(self,
            selector: #selector(updateSources(notification:)),
            name: .browseSearch,
            object: nil
        )
        NotificationCenter.default.addObserver(self,
            selector: #selector(isOnPlaylist(notification:)),
            name: .addedToPlaylist,
            object: nil
        )
    }

    func updateSources(notification: NSNotification) {
        guard let sources = notification.object as? [SearchResultObject] else { return }
        
        sourcesList = sources
        tableView.reloadData()
        clearAllNotice()
    }
    
    func isOnPlaylist(notification:NSNotification) {
        self.clearAllNotice()
        
        guard let object = notification.object else { return }
        
        noticeTop(
            localizedAddedItemToPlaylistNotice(name: String(describing: object)),
            autoClear: true,
            autoClearTime: 3
        )
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
        
        if item.type == .song {
            let cell = tableView.dequeueReusableCell(withIdentifier: "track", for: indexPath) as! TrackTableViewCell
            
            cell.trackTitle.text = item.localizedTitle
            cell.trackArtist.text = item.localizedArtistAndAlbum
            
            cell.trackImage.image = nil // TODO: quickfix for cell reuse

            if item.albumArt?.range(of:"http") != nil{
                cell.trackImage.contentMode = .scaleAspectFill
                cell.trackImage.kf.setImage(with: URL(string: item.albumArt!), placeholder: UIImage(named: "background"), options: [.transition(.fade(0.2))])
            } else {
                
                if let artist = item.artist, let album = item.album {
                    LastFMService.shared.albumGetImageURL(artist: artist, album: album, completion: { (albumUrl) in
                        if let albumUrl = albumUrl {
                            DispatchQueue.main.async {
                                cell.trackImage.contentMode = .scaleAspectFill
                                cell.trackImage.kf.setImage(with: albumUrl, placeholder: UIImage(named: "background"), options: [.transition(.fade(0.2))])
                            }
                        }
                    })
                }
            }
            
            return cell
            
        } else if item.type.isRadio {
            let cell = tableView.dequeueReusableCell(withIdentifier: "radio", for: indexPath) as! FolderTableViewCell
            
            cell.folderTitle.text = item.title ?? ""
            if item.albumArt?.range(of:"http") != nil{
                cell.folderImage.contentMode = .scaleAspectFill
                cell.folderImage.kf.setImage(with: URL(string: item.albumArt!), placeholder: UIImage(named: "radio"), options: [.transition(.fade(0.2))])
            } else {
                cell.folderImage.contentMode = .center
                cell.folderImage.image = UIImage(named: "radio")
            }
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "folder", for: indexPath) as! FolderTableViewCell
            
            cell.folderTitle.text = item.title ?? ""
            if item.albumArt?.range(of:"http") != nil{
                cell.folderImage.contentMode = .scaleAspectFill
                cell.folderImage.kf.setImage(with: URL(string: item.albumArt!), placeholder: UIImage(named: "folder"), options: [.transition(.fade(0.2))])
            } else {
                cell.folderImage.contentMode = .center
                cell.folderImage.image = UIImage(named: "folder")
            }
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
        
        let play = UITableViewRowAction(
            style: .normal,
            title: localizedPlayTitle
        ) { (action, index) in
            guard let uri = item.uri, let title = item.title, let service = item.service
                else { return }
            VolumioIOManager.shared.addAndPlay(uri: uri, title: title, service: service)
            tableView.setEditing(false, animated: true)
        }
        play.backgroundColor = UIColor(red: 74.0/255.0, green: 190.0/255.0, blue: 134.0/255.0, alpha: 1)
        
        let more = UITableViewRowAction(
            style: .normal,
            title: localizedMoreTitle
        ) { (action, index) in
            self.playlistActions(item: item)
            tableView.setEditing(false, animated: true)
        }
        more.backgroundColor = UIColor(red: 76.0/255.0, green: 71.0/255.0, blue: 70.0/255.0, alpha: 1)
        
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
            UIAlertAction(title: localizedPlayTitle, style: .default) {
                (action) in
                    VolumioIOManager.shared.addAndPlay(
                        uri: itemUri,
                        title: itemTitle,
                        service: itemService
                    )
        })
        alert.addAction(
            UIAlertAction(title: localizedAddToQueueTitle, style: .default) {
                (action) in
                    VolumioIOManager.shared.addToQueue(
                        uri: itemUri,
                        title: itemTitle,
                        service: itemService
                    )
        })
        alert.addAction(
            UIAlertAction(title: localizedClearAndPlayTitle, style: .default) {
                (action) in
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
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
                
            let itemList = sourcesList[indexPath.section]
            let items = itemList.items
            if let items = items {
                let item = items[indexPath.row] as LibraryObject
            
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
