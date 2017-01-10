//
//  QueueTableViewController.swift
//  Volumio
//
//  Created by Federico Sintucci on 03/10/16.
//  Copyright © 2016 Federico Sintucci. All rights reserved.
//

import UIKit
import Kingfisher
import Fabric

class QueueTableViewController: UITableViewController, QueueActionsDelegate {
    
    var queue : [TrackObject] = []
    var headerView: QueueActions?
    var queuePointer : Int = 0
    
    var track : TrackObject!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        SocketIOManager.sharedInstance.getState()
        registerObservers()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.pleaseWait()
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        self.refreshControl?.addTarget(self, action: #selector(handleRefresh), for: UIControlEvents.valueChanged)
        
        // HeaderView
        let frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 56.0)
        headerView = QueueActions(frame: frame)
        headerView?.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.clearAllNotice()
        NotificationCenter.default.removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private func registerObservers() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(getQueue(notification:)), name: NSNotification.Name("currentQueue"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(getCurrentTrack(notification:)), name: NSNotification.Name("currentTrack"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(removeFromQueue(notification:)), name: NSNotification.Name("removedfromQueue"), object: nil)
    }
    
    func getQueue(notification:NSNotification) {
        if let sources = notification.object as? [TrackObject] {
            self.queue = sources
            self.tableView.reloadData()
            self.clearAllNotice()
        }
    }
    
    func getCurrentTrack(notification:NSNotification) {
        if let track = notification.object as? TrackObject,
            let position = track.position {
            self.track = track
            self.queuePointer = position
            self.headerView?.updateStatus(track: track)
        }
        SocketIOManager.sharedInstance.getQueue()
    }
    
    func removeFromQueue(notification:NSNotification) {
        SocketIOManager.sharedInstance.getQueue()
        let waitTime = DispatchTime.now() + .milliseconds(500)
        DispatchQueue.main.asyncAfter(deadline: waitTime, execute: {
            self.noticeTop("Removed from queue", autoClear: true, autoClearTime: 3)
        })
        
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
        if let artist = track.artist,
            let album = track.album {
            cell.trackArtist.text = "\(artist) - \(album)"            
        }
        
        cell.trackPosition.text = "\(indexPath.row + 1)"
                
        if indexPath.row == queuePointer {
            cell.trackPlaying.isHidden = false
            cell.backgroundColor = UIColor.black.withAlphaComponent(0.05)
        } else {
            cell.trackPlaying.isHidden = true
            cell.backgroundColor = UIColor.white
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
            SocketIOManager.sharedInstance.removeFromQueue(position: indexPath.row)
        }   
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        SocketIOManager.sharedInstance.playTrack(position: indexPath.row)
        SocketIOManager.sharedInstance.getState()
    }
    
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        SocketIOManager.sharedInstance.sortQueue(from: sourceIndexPath.row, to:destinationIndexPath.row)
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 54.0
    }

    @IBAction func editRowOrder(_ sender: UIBarButtonItem) {
        self.isEditing = !self.isEditing
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 56.0
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        SocketIOManager.sharedInstance.getQueue()
        refreshControl.endRefreshing()
    }

    // MARK: - QueueActionsDelegate
    func didRepeat() {
        if let track = track, let repetition = track.repetition {
            switch repetition {
            case 0: SocketIOManager.sharedInstance.toggleRepeat(value: 1)
            default: SocketIOManager.sharedInstance.toggleRepeat(value: 0)
            }
        } else {
            SocketIOManager.sharedInstance.toggleRepeat(value: 1)
        }
    }
    
    func didShuffle() {
        if let track = track, let shuffle = track.shuffle {
            switch shuffle {
            case 0: SocketIOManager.sharedInstance.toggleRandom(value: 1)
            default: SocketIOManager.sharedInstance.toggleRandom(value: 0)
            }
        } else {
            SocketIOManager.sharedInstance.toggleRandom(value: 1)
        }
    }
    
    func didConsume() {
        if let track = track, let consume = track.consume {
            switch consume {
            case 0: SocketIOManager.sharedInstance.toggleConsume(value: 1)
            default: SocketIOManager.sharedInstance.toggleConsume(value: 0)
            }
        } else {
            SocketIOManager.sharedInstance.toggleConsume(value: 1)
        }
    }
    
    func didClear() {
        SocketIOManager.sharedInstance.clearQueue()
    }

}
