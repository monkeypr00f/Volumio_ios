//
//  BrowsePlaylistsTableViewController.swift
//  Volumio-iOS
//
//  Created by Federico Sintucci on 10/10/16.
//  Copyright © 2016 Federico Sintucci. All rights reserved.
//

import UIKit

class BrowsePlaylistsTableViewController: UITableViewController {

    var serviceName : String!
    var serviceUri : String!
    
    var sourcePlaylists : [LibraryObject] = []
    
    override func viewWillAppear(_ animated: Bool) {
        SocketIOManager.sharedInstance.browseLibrary(uri: serviceUri)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = serviceName
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("browseLibrary"), object: nil, queue: nil, using: { notification in
            if let sources = SocketIOManager.sharedInstance.currentLibrary {
                self.sourcePlaylists = sources
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
        return sourcePlaylists.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "playlist", for: indexPath) as! PlaylistTableViewCell
        let playlist = sourcePlaylists[indexPath.row]
        
        cell.playlistTitle.text = playlist.title ?? ""
        
        if playlist.albumArt?.range(of:"http") != nil{
            cell.playlistImage.kf.setImage(with: URL(string: playlist.albumArt!), placeholder: UIImage(named: "background"), options: [.transition(.fade(0.2))])
        }
        
        return cell
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        self.tableView.reloadData()
        refreshControl.endRefreshing()
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showTracks" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let destinationController = segue.destination as! BrowseTracksTableViewController
                destinationController.serviceName = sourcePlaylists[indexPath.row].title
                destinationController.serviceUri = sourcePlaylists[indexPath.row].uri
                destinationController.serviceService = sourcePlaylists[indexPath.row].service
            }
        }
    }

}
