//
//  BrowseTracksTableViewController.swift
//  Volumio-iOS
//
//  Created by Federico Sintucci on 12/10/16.
//  Copyright © 2016 Federico Sintucci. All rights reserved.
//

import UIKit
import Kingfisher

class BrowseTracksTableViewController: UITableViewController {
    
    var serviceName : String!
    var serviceUri : String!
    var serviceService : String!
    
    var sourcePlaylist : [LibraryObject] = []
    
    override func viewWillAppear(_ animated: Bool) {
        SocketIOManager.sharedInstance.browseLibrary(uri: serviceUri)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = serviceName
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("browseLibrary"), object: nil, queue: nil, using: { notification in
            if let sources = SocketIOManager.sharedInstance.currentLibrary {
                self.sourcePlaylist = sources
                self.tableView.reloadData()
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
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sourcePlaylist.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "track", for: indexPath) as! TrackTableViewCell
        let playlist = sourcePlaylist[indexPath.row]
        
        cell.trackTitle.text = playlist.title ?? ""
        let artist = playlist.artist ?? ""
        let album = playlist.album ?? ""
        cell.trackArtist.text = "\(artist) - \(album)"
        
        if playlist.albumArt?.range(of:"http") != nil{
            cell.trackImage.kf.setImage(with: URL(string: playlist.albumArt!), placeholder: UIImage(named: "background"), options: [.transition(.fade(0.2))])
        } else {
            if playlist.service == "spop" {
                cell.trackImage.image = UIImage(named: "spotifyIcon")
            }
        }
        
        return cell
    }
    
    @IBAction func playlistOptionButton(_ sender: UIBarButtonItem) {
        playlistActions()
    }
    
    func playlistActions() {
        let alert = UIAlertController(title: "Volumio", message: "", preferredStyle: .actionSheet)
        alert.addAction(
            UIAlertAction(title: "Play", style: .default, handler: { (action) in
                SocketIOManager.sharedInstance.addAndPlay(uri: self.serviceUri, title: self.serviceName, service: self.serviceService)
            })
        )
        alert.addAction(
            UIAlertAction(title: "Add to queue", style: .default, handler: { (action) in
                SocketIOManager.sharedInstance.addToQueue(uri: self.serviceUri, title: self.serviceName, service: self.serviceService)
            })
        )
        alert.addAction(
            UIAlertAction(title: "Clear and Play", style: .default, handler: { (action) in
                SocketIOManager.sharedInstance.clearAndPlay(uri: self.serviceUri, title: self.serviceName, service: self.serviceService)
            })
        )
//        alert.addAction(
//            UIAlertAction(title: "Add to playlist", style: .default, handler: { (action) in
//                SocketIOManager.sharedInstance.doAction(action: "reboot")
//            })
//        )
        alert.addAction(
            UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        )
        self.present(alert, animated: true, completion: nil)
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        self.tableView.reloadData()
        refreshControl.endRefreshing()
    }


}
