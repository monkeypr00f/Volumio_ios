//
//  PlaylistAddViewController.swift
//  Volumio
//
//  Created by Federico Sintucci on 07/11/16.
//  Copyright © 2016 Federico Sintucci. All rights reserved.
//

import UIKit

class PlaylistAddViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var playlists : [Any] = []
    var track : TrackObject!

    @IBOutlet weak var inputPlaylist: UITextField!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerObservers()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.pleaseWait()
        
        SocketIOManager.sharedInstance.listPlaylist()
        if let currentTrackInfo = SocketIOManager.sharedInstance.currentTrack {
            self.track = currentTrackInfo
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        inputPlaylist.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    private func registerObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(getPlaylist(notification:)), name: NSNotification.Name("listPlaylists"), object: nil)
    }
    
    func getPlaylist(notification: NSNotification) {
        if let sources = notification.object as? [Any] {
            self.playlists = sources
            self.tableView.reloadData()
            self.clearAllNotice()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 54.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playlists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "playlist", for: indexPath) as! AddToPlaylistTableViewCell
        let playlist = playlists[indexPath.row] as! String
        
        cell.playlistName.text = playlist
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedPlaylist = playlists[indexPath.row] as! String
        if let currentTrackUri = track.uri,
            let currentTrackService = track.service {
            SocketIOManager.sharedInstance.addToPlaylist(name: selectedPlaylist, uri: currentTrackUri, service: currentTrackService)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let name = inputPlaylist.text {
            if let currentTrackTitle = track.title,
                let currentTrackUri = track.uri,
                let currentTrackService = track.service {
                
                SocketIOManager.sharedInstance.createPlaylist(name: name, title:currentTrackTitle, uri:currentTrackUri, service:currentTrackService)
                self.dismiss(animated: true, completion: nil)
                inputPlaylist.resignFirstResponder()
            }
        }
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func closeButton(_ sender: UIButton) {
        self.clearAllNotice()
        self.dismiss(animated: true, completion: nil)
    }

}
