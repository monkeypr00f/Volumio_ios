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
        
        registerObservers()

        VolumioIOManager.shared.getState()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        localize()

        pleaseWait()
        
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        self.refreshControl?.addTarget(self,
            action: #selector(handleRefresh),
            for: UIControlEvents.valueChanged
        )
        
        // HeaderView
        let frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 56.0)
        headerView = QueueActions(frame: frame)
        headerView?.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        clearAllNotice()
        
        NotificationCenter.default.removeObserver(self)
    }

    private func registerObservers() {
        
        NotificationCenter.default.addObserver(self,
            selector: #selector(getQueue(notification:)),
            name: .currentQueue,
            object: nil
        )
        NotificationCenter.default.addObserver(self,
            selector: #selector(getCurrentTrack(notification:)),
            name: .currentTrack,
            object: nil
        )
        NotificationCenter.default.addObserver(self,
            selector: #selector(removeFromQueue(notification:)),
            name: .removedfromQueue,
            object: nil
        )
    }
    
    func getQueue(notification: NSNotification) {
        guard let sources = notification.object as? [TrackObject] else { return }
        
        queue = sources
        tableView.reloadData()
        clearAllNotice()
    }
    
    func getCurrentTrack(notification: NSNotification) {
        if let currentTrack = notification.object as? TrackObject,
           let position = currentTrack.position
        {
            track = currentTrack
            queuePointer = position
            headerView?.updateStatus(track: track)
        }
        VolumioIOManager.shared.getQueue()
    }
    
    func removeFromQueue(notification: NSNotification) {
        VolumioIOManager.shared.getQueue()
        let waitTime = DispatchTime.now() + .milliseconds(500)
        DispatchQueue.main.asyncAfter(deadline: waitTime, execute: {
            self.noticeTop(self.localizedRemovedNotice, autoClear: true, autoClearTime: 3)
        })
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return queue.count
    }

    override func tableView(_ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
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

    override func tableView(_ tableView: UITableView,
        canEditRowAt indexPath: IndexPath
    ) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView,
        commit editingStyle: UITableViewCellEditingStyle,
        forRowAt indexPath: IndexPath
    ) {
        if editingStyle == .delete {
            VolumioIOManager.shared.removeFromQueue(position: indexPath.row)
        }   
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        VolumioIOManager.shared.playTrack(position: indexPath.row)
        VolumioIOManager.shared.getState()
    }
    
    
    override func tableView(_ tableView: UITableView,
        moveRowAt sourceIndexPath: IndexPath,
        to destinationIndexPath: IndexPath
    ) {
        VolumioIOManager.shared.sortQueue(
            from: sourceIndexPath.row,
            to:destinationIndexPath.row
        )
    }
    
    override func tableView(_ tableView: UITableView,
        canMoveRowAt indexPath: IndexPath
    ) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        return 54.0
    }

    @IBAction func editRowOrder(_ sender: UIBarButtonItem) {
        self.isEditing = !self.isEditing
    }
    
    override func tableView(_ tableView: UITableView,
        viewForHeaderInSection section: Int
    ) -> UIView? {
        return headerView
    }
    
    override func tableView(_ tableView: UITableView,
        heightForHeaderInSection section: Int
    ) -> CGFloat {
        return 56.0
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        VolumioIOManager.shared.getQueue()
        refreshControl.endRefreshing()
    }

    // MARK: - QueueActionsDelegate
    
    func didRepeat() {
        if let track = track, let repetition = track.repetition {
            switch repetition {
            case 0: VolumioIOManager.shared.toggleRepeat(value: 1)
            default: VolumioIOManager.shared.toggleRepeat(value: 0)
            }
        } else {
            VolumioIOManager.shared.toggleRepeat(value: 1)
        }
    }
    
    func didShuffle() {
        if let track = track, let shuffle = track.shuffle {
            switch shuffle {
            case 0: VolumioIOManager.shared.toggleRandom(value: 1)
            default: VolumioIOManager.shared.toggleRandom(value: 0)
            }
        } else {
            VolumioIOManager.shared.toggleRandom(value: 1)
        }
    }
    
    func didConsume() {
        if let track = track, let consume = track.consume {
            switch consume {
            case 0: VolumioIOManager.shared.toggleConsume(value: 1)
            default: VolumioIOManager.shared.toggleConsume(value: 0)
            }
        } else {
            VolumioIOManager.shared.toggleConsume(value: 1)
        }
    }
    
    func didClear() {
        VolumioIOManager.shared.clearQueue()
    }

}

// MARK: - Localization

extension QueueTableViewController {
    
    fileprivate func localize() {
        navigationItem.title = NSLocalizedString("QUEUE",
            comment: "queue view title"
        )
    }
    
    fileprivate var localizedRemovedNotice: String {
        return NSLocalizedString("QUEUE_REMOVED_ITEM",
            comment: "removed item from queue"
        )
    }

}
