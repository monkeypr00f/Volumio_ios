//
//  BrowseFolderTableViewController.swift
//  Volumio-iOS
//
//  Created by Federico Sintucci on 24/10/16.
//  Copyright © 2016 Federico Sintucci. All rights reserved.
//

import UIKit

class BrowseFolderTableViewController: UITableViewController {

    var serviceName : String!
    var serviceUri : String!
    
    var sourceLibrary : [LibraryObject] = []

    override func viewDidAppear(_ animated: Bool) {
        SocketIOManager.sharedInstance.browseLibrary(uri: serviceUri)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let hideSwipeTutorial = UserDefaults.standard.bool(forKey: "hideSwipeTutorial")
        if hideSwipeTutorial == false {
            performSegue(withIdentifier: "segueToTutorial", sender: self)
        }
        
        self.title = serviceName
        self.pleaseWait()
        
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("browseLibrary"), object: nil, queue: nil, using: { notification in
            if let sources = SocketIOManager.sharedInstance.currentLibrary {
                self.sourceLibrary = sources
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

    override func viewWillDisappear(_ animated: Bool) {
        self.clearAllNotice()
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
         
        } else if sourceLibrary[indexPath.row].type == "webradio" {
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
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {

    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let play = UITableViewRowAction(style: .normal, title: "Play") { action, index in
            SocketIOManager.sharedInstance.addAndPlay(uri:self.sourceLibrary[indexPath.row].uri!, title: self.sourceLibrary[indexPath.row].title!, service: self.sourceLibrary[indexPath.row].service! )
            tableView.setEditing(false, animated: true)
        }
        play.backgroundColor = UIColor(red: 74.0/255.0, green: 190/255.0, blue: 134/255.0, alpha: 1)
        
        let more = UITableViewRowAction(style: .normal, title: "More") { action, index in
            self.playlistActions(item: self.sourceLibrary[indexPath.row])
            tableView.setEditing(false, animated: true)
        }
        play.backgroundColor = UIColor.lightGray
        
        return [more, play]
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 54.0
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        SocketIOManager.sharedInstance.browseLibrary(uri: serviceUri)
        refreshControl.endRefreshing()
    }
    
    func playlistActions(item:LibraryObject) {
        let alert = UIAlertController(title: "Volumio", message: "", preferredStyle: .actionSheet)
        alert.addAction(
            UIAlertAction(title: "Play", style: .default, handler: { (action) in
                SocketIOManager.sharedInstance.addAndPlay(uri: item.uri!, title: item.title!, service: item.service!)
            })
        )
        alert.addAction(
            UIAlertAction(title: "Add to queue", style: .default, handler: { (action) in
                SocketIOManager.sharedInstance.addToQueue(uri: item.uri!, title: item.title!, service: item.service!)
            })
        )
        alert.addAction(
            UIAlertAction(title: "Clear and Play", style: .default, handler: { (action) in
                SocketIOManager.sharedInstance.clearAndPlay(uri: item.uri!, title: item.title!, service: item.service!)
            })
        )
        alert.addAction(
            UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        )
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "segueFolder" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let destinationController = segue.destination as! BrowseFolderTableViewController
                destinationController.serviceName = sourceLibrary[indexPath.row].title
                destinationController.serviceUri = sourceLibrary[indexPath.row].uri
            }
        }
    }
    
}
