//
//  PlaybackViewController.swift
//  Volumio-iOS
//
//  Created by Federico Sintucci on 20/09/16.
//  Copyright © 2016 Federico Sintucci. All rights reserved.
//

import UIKit
import Kingfisher

class PlaybackViewController: UIViewController {
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var currentAlbum: UILabel!
    @IBOutlet weak var currentTitle: UILabel!
    @IBOutlet weak var currentArtist: UILabel!
    @IBOutlet weak var currentAlbumArt: UIImageView!
    @IBOutlet weak var spotifyTrack: UIImageView!
    @IBOutlet weak var currentProgress: UIProgressView!
    @IBOutlet weak var currentVolume: UILabel!

    @IBOutlet weak var outerRing: UIView!
    @IBOutlet weak var centerRing: UIView!
    @IBOutlet weak var innerRing: UIView!
    @IBOutlet weak var volumeController: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SocketIOManager.sharedInstance.getState()
        SocketIOManager.sharedInstance.browseSources()
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("currentTrack"), object: nil, queue: nil, using: { notification in
            self.getCurrentTrackInfo()
            self.getPlayerStatus()
        })
        
        NotificationCenter.default.addObserver(self, selector: #selector(getCurrentTrackInfo), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(getPlayerStatus), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        innerRing.makeCircle()
        centerRing.makeCircle()
        outerRing.makeCircle()
        
        volumeController.layer.borderWidth = 1
        volumeController.layer.borderColor = UIColor(red: 205/255, green: 205/255, blue: 205/255, alpha: 1).cgColor
        volumeController.layer.shadowColor = UIColor.black.cgColor
        volumeController.layer.shadowOpacity = 0.1
        volumeController.layer.shadowOffset = CGSize.zero
        volumeController.layer.shadowRadius = 20
        volumeController.layer.shadowPath = UIBezierPath(rect: volumeController.bounds).cgPath
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func pressPlay(_ sender: UIButton) {
        switch SocketIOManager.sharedInstance.currentTrack![0].status! {
        case "play":
            SocketIOManager.sharedInstance.setPlayback(status: "pause")
        case "pause":
            SocketIOManager.sharedInstance.setPlayback(status: "play")
        case "stop":
            SocketIOManager.sharedInstance.setPlayback(status: "play")
        default:
            SocketIOManager.sharedInstance.setPlayback(status: "stop")
        }
        getPlayerStatus()
    }
    
    @IBAction func pressPrevious(_ sender: UIButton) {
        SocketIOManager.sharedInstance.prevTrack()
    }
    
    @IBAction func pressNext(_ sender: UIButton) {
        SocketIOManager.sharedInstance.nextTrack()
    }
    
    @IBAction func pressVolumeUp(_ sender: UIButton) {
        if var volume = SocketIOManager.sharedInstance.currentTrack![0].volume {
            if volume < 100 {
                volume += 5
                currentVolume.text = "\(volume)"
                SocketIOManager.sharedInstance.setVolume(value: volume)
            }
        }
    }
    
    @IBAction func pressVolumeDown(_ sender: UIButton) {
        if var volume = SocketIOManager.sharedInstance.currentTrack![0].volume {
            if volume > 0 {
                volume -= 5
                currentVolume.text = "\(volume)"
                SocketIOManager.sharedInstance.setVolume(value: volume)
            }
        }
    }
    
    func getPlayerStatus() {
        if let status = SocketIOManager.sharedInstance.currentTrack![0].status {
            switch status {
            case "play":
                self.playButton.setImage(UIImage(named: "pause"), for: UIControlState.normal)
            case "pause":
                self.playButton.setImage(UIImage(named: "play"), for: UIControlState.normal)
            case "stop":
                self.playButton.setImage(UIImage(named: "play"), for: UIControlState.normal)
            default:
                self.playButton.setImage(UIImage(named: "stop"), for: UIControlState.normal)
            }
        }
    }
    
    func getCurrentTrackInfo() {
        
        let currentTrackInfo = SocketIOManager.sharedInstance.currentTrack![0]
        currentAlbum.text = currentTrackInfo.album!
        currentTitle.text = currentTrackInfo.title!
        currentArtist.text = currentTrackInfo.artist!
        currentAlbumArt.kf.indicatorType = .activity
        
        if let volume = currentTrackInfo.volume {
            currentVolume.text = "\(volume)"
        }
        
       if currentTrackInfo.albumArt!.range(of:"http") != nil{
            currentAlbumArt.kf.setImage(with: URL(string: currentTrackInfo.albumArt!), placeholder: UIImage(named: "background"), options: [.transition(.fade(0.2)), .forceRefresh])
        } else {
            LastFmManager.sharedInstance.getAlbumArt(artist: currentTrackInfo.artist!, album: currentTrackInfo.album!, completionHandler: { (albumUrl) in
                if let albumUrl = albumUrl {
                    DispatchQueue.main.async {
                        self.currentAlbumArt.kf.setImage(with: URL(string: albumUrl), placeholder: UIImage(named: "background"), options: [.transition(.fade(0.2)), .forceRefresh])
                    }
                }
            })
        }
        
        if currentTrackInfo.service! == "spop" {
            spotifyTrack.isHidden = false
        }
    }
}

extension UIView {
    
    func makeCircle() {
        self.layer.cornerRadius = self.frame.size.width/2
        self.clipsToBounds = true
    }
}
