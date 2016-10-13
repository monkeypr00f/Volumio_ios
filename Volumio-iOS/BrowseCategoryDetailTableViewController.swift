//
//  BrowseCategoryDetailTableViewController.swift
//  Volumio-iOS
//
//  Created by Federico Sintucci on 10/10/16.
//  Copyright © 2016 Federico Sintucci. All rights reserved.
//

import UIKit

class BrowseCategoryDetailTableViewController: UITableViewController {

    var serviceName : String!
    var serviceUri : String!
    
    var sourceCategory : [LibraryObject] = []
    
    override func viewWillAppear(_ animated: Bool) {
        SocketIOManager.sharedInstance.browseLibrary(uri: serviceUri)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        self.title = serviceName
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("browseLibrary"), object: nil, queue: nil, using: { notification in
            if let sources = SocketIOManager.sharedInstance.currentLibrary {
                self.sourceCategory = sources
                self.tableView.reloadData()
            }
        })
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
        return sourceCategory.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "browsePlaylist", for: indexPath) as! PlaylistTableViewCell
        let playlist = sourceCategory[indexPath.row]
        
        cell.playlistTitle.text = playlist.title ?? ""
        
        if playlist.albumArt?.range(of:"http") != nil{
            cell.playlistImage.kf.setImage(with: URL(string: (playlist.albumArt)!), placeholder: UIImage(named: "background"), options: [.transition(.fade(0.2))])
        }

        return cell
    }
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "browsePlaylist" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let destinationController = segue.destination as! BrowsePlaylistsTableViewController
                destinationController.serviceName = sourceCategory[indexPath.row].title
                destinationController.serviceUri = sourceCategory[indexPath.row].uri
            }
        }
    }

}
