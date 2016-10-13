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

        
    override func viewDidLoad() {
        super.viewDidLoad()

        SocketIOManager.sharedInstance.getQueue()
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("currentPlaylist"), object: nil, queue: nil, using: { notification in
            if let sources = SocketIOManager.sharedInstance.currentPlaylist {
                self.queue = sources
                self.tableView.reloadData()
            }
        })
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("currentTrack"), object: nil, queue: nil, using: { notification in
            // da modificare, controlla quella che sta suonando
            self.tableView.reloadData()
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
        return queue.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "track", for: indexPath) as! TrackTableViewCell
        let track = queue[indexPath.row]
        
        cell.trackTitle.text = track.title ?? ""
        let artist = track.artist ?? ""
        let album = track.album ?? ""
        cell.trackArtist.text = "\(artist) - \(album)"
        
        if let position = SocketIOManager.sharedInstance.currentTrack?.position {
            if indexPath.row == position {
                cell.trackPlaying.isHidden = false
            }
        }
        
        if track.albumArt!.range(of:"http") != nil{
            cell.trackImage.kf.setImage(with: URL(string: (track.albumArt)!), placeholder: UIImage(named: "background"), options: [.transition(.fade(0.2))])
        } else {
            LastFmManager.sharedInstance.getAlbumArt(artist: track.artist!, album: track.album!, completionHandler: { (albumUrl) in
                if let albumUrl = albumUrl {
                    DispatchQueue.main.async {
                        cell.trackImage.kf.setImage(with: URL(string: albumUrl), placeholder: UIImage(named: "background"), options: [.transition(.fade(0.2))])
                    }
                }
            })
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

}
