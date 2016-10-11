//
//  BrowsePlaylistDetailTableViewController.swift
//  Volumio-iOS
//
//  Created by Federico Sintucci on 10/10/16.
//  Copyright © 2016 Federico Sintucci. All rights reserved.
//

import UIKit

class BrowsePlaylistDetailTableViewController: UITableViewController {

    var serviceName : String!
    var serviceUri : String!
    
    var sourceCategory : [LibraryObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = serviceName
        SocketIOManager.sharedInstance.browseLibrary(uri: serviceUri)
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
        
        if playlist.albumart!.range(of:"http") != nil{
            cell.playlistImage.kf.setImage(with: URL(string: (playlist.albumart)!), placeholder: UIImage(named: "background"), options: [.transition(.fade(0.2))])
        }

        return cell
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
