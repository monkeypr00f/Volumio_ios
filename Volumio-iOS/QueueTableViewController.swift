//
//  QueueTableViewController.swift
//  Volumio-iOS
//
//  Created by Federico Sintucci on 03/10/16.
//  Copyright © 2016 Federico Sintucci. All rights reserved.
//

import UIKit
import Kingfisher

class QueueTableViewController: UITableViewController {
    
     var queue : [TrackObject] = []
    
    override func viewWillAppear(_ animated: Bool) {
        SocketIOManager.sharedInstance.getState()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.pleaseWait()

        SocketIOManager.sharedInstance.getQueue()
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("currentQueue"), object: nil, queue: nil, using: { notification in
            if let sources = SocketIOManager.sharedInstance.currentPlaylist {
                self.queue = sources
                self.tableView.reloadData()
                self.clearAllNotice()
            }
        })
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("currentTrack"), object: nil, queue: nil, using: { notification in
            self.tableView.reloadData()
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
        return queue.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "track", for: indexPath) as! QueueTableViewCell
        let track = queue[indexPath.row]
        
        cell.trackTitle.text = track.name ?? ""
        let artist = track.artist ?? ""
        let album = track.album ?? ""
        cell.trackArtist.text = "\(artist) - \(album)"
        cell.trackPosition.text = "\(indexPath.row + 1)"
                
        if let position = SocketIOManager.sharedInstance.currentTrack?.position {
            if indexPath.row == Int(position) {
                cell.trackPlaying.isHidden = false
                cell.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.05)
            } else {
                cell.trackPlaying.isHidden = true
                cell.backgroundColor = UIColor.white
            }
        }
        
        if track.albumArt!.range(of:"http") != nil{
            cell.trackImage.kf.setImage(with: URL(string: (track.albumArt)!), placeholder: UIImage(named: "background"), options: [.transition(.fade(0.2))])
        } else {
            if let artist = track.artist, let album = track.album {
                LastFmManager.sharedInstance.getAlbumArt(artist: artist, album: album, completionHandler: { (albumUrl) in
                    if let albumUrl = albumUrl {
                        DispatchQueue.main.async {
                            cell.trackImage.kf.setImage(with: URL(string: albumUrl), placeholder: UIImage(named: "background"), options: [.transition(.fade(0.2))])
                        }
                    }
                })
            }
        }
        
        return cell
    }

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            SocketIOManager.sharedInstance.removeFromQueue(position: indexPath.row)
        }   
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        SocketIOManager.sharedInstance.playTrack(position: indexPath.row)
        DispatchQueue.main.async {
            tableView.reloadData()
        }
    }

    @IBAction func editRowOrder(_ sender: UIBarButtonItem) {
        self.isEditing = !self.isEditing
    }
    
    // Override to support rearranging the table view.
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        SocketIOManager.sharedInstance.sortQueue(from: sourceIndexPath.row, to:destinationIndexPath.row)
    }

    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        SocketIOManager.sharedInstance.getQueue()
        refreshControl.endRefreshing()
    }

}
