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
    @IBOutlet weak var currentAddToFavourite: UIButton!
    @IBOutlet weak var currentAddToPlaylist: UIButton!
    @IBOutlet weak var spotifyTrack: UIImageView!
    @IBOutlet weak var repeatButton: UIButton!
    @IBOutlet weak var shuffleButton: UIButton!
    
    @IBOutlet weak var currentProgress: UIProgressView!
    @IBOutlet weak var currentVolume: UILabel!
    @IBOutlet weak var seekValue: UILabel!
    @IBOutlet weak var currentDuration: UILabel!

    @IBOutlet weak var outerRing: UIView!
    @IBOutlet weak var innerRing: UIView!
    @IBOutlet weak var playerView: UIView!
    @IBOutlet weak var playerViewShadow: UIView!
    
    var counter: Int = 0
    var trackDuration: Int = 0
    var currentTrackInfo:TrackObject!
    var timer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let logo = UIImage(named: "logo")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
        
        SocketIOManager.sharedInstance.getState()
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("currentTrack"), object: nil, queue: nil, using: { notification in
            self.getCurrentTrackInfo()
        })
        
        NotificationCenter.default.addObserver(self, selector: #selector(getCurrentTrackInfo), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        innerRing.makeCircle()
        outerRing.makeCircle()
        
        playerViewShadow.layer.shadowOffset = CGSize.zero
        playerViewShadow.layer.shadowOpacity = 1
        playerViewShadow.layer.shadowRadius = 3
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func pressPlay(_ sender: UIButton) {
        switch SocketIOManager.sharedInstance.currentTrack!.status! {
        case "play":
            SocketIOManager.sharedInstance.doAction(action: "pause")
        case "pause":
            SocketIOManager.sharedInstance.doAction(action: "play")
        case "stop":
            SocketIOManager.sharedInstance.doAction(action: "play")
        default:
            SocketIOManager.sharedInstance.doAction(action: "stop")
        }
        getPlayerStatus()
    }
    
    @IBAction func pressPrevious(_ sender: UIButton) {
        SocketIOManager.sharedInstance.doAction(action: "prev")
    }
    
    @IBAction func pressNext(_ sender: UIButton) {
        SocketIOManager.sharedInstance.doAction(action: "next")
    }
    
    @IBAction func pressVolumeUp(_ sender: UIButton) {
        if var volume = SocketIOManager.sharedInstance.currentTrack!.volume {
            if volume < 100 {
                volume += 5
                currentVolume.text = "\(volume)"
                SocketIOManager.sharedInstance.setVolume(value: volume)
            }
        }
    }
    
    @IBAction func pressVolumeDown(_ sender: UIButton) {
        if var volume = SocketIOManager.sharedInstance.currentTrack!.volume {
            if volume > 0 {
                volume -= 5
                currentVolume.text = "\(volume)"
                SocketIOManager.sharedInstance.setVolume(value: volume)
            }
        }
    }

    @IBAction func toggleRepeat(_ sender: UIButton) {
        
        if let repetition = currentTrackInfo.repetition {
            switch repetition {
            case "1":SocketIOManager.sharedInstance.toggleRepeat(value: "0")
            case "0":SocketIOManager.sharedInstance.toggleRepeat(value: "1")
            default:SocketIOManager.sharedInstance.toggleRepeat(value: "1")
            }
            getCurrentTrackInfo()
        }
    }
    
    @IBAction func toggleShuffle(_ sender: UIButton) {
        
        if let shuffle = currentTrackInfo.shuffle {
            switch shuffle {
            case "1": SocketIOManager.sharedInstance.toggleRandom(value: "0")
            case "0":SocketIOManager.sharedInstance.toggleRandom(value: "1")
            default:SocketIOManager.sharedInstance.toggleRandom(value: "1")
            }
            getCurrentTrackInfo()
        }
    }
    
    func getCurrentTrackInfo() {
                        
        currentTrackInfo = SocketIOManager.sharedInstance.currentTrack!
        
        if let album = currentTrackInfo.album {
            currentAlbum.text = album
            currentAlbum.isHidden = false
        }
        
        if let title = currentTrackInfo.title {
            currentTitle.text = title
            currentTitle.isHidden = false
        }
        
        if let artist = currentTrackInfo.artist {
            currentArtist.text = artist
            currentArtist.isHidden = false
        }
        
        currentAddToFavourite.isHidden = false
        currentAddToPlaylist.isHidden = false
        
        if let volume = currentTrackInfo.volume {
            currentVolume.text = "\(volume)"
        } else {
            SocketIOManager.sharedInstance.setVolume(value: 50)
        }
        
        if let duration = currentTrackInfo.duration {
            trackDuration = duration
            currentDuration.text = timeFormatted(totalSeconds: duration)
            if let seek = currentTrackInfo.seek {
                counter = seek
                seekValue.text = timeFormatted(totalSeconds: counter/1000)
                
                let percentage = Float(counter) / (Float(trackDuration) * 1000)
                currentProgress.setProgress(percentage, animated: true)
            }
        }

        if currentTrackInfo.albumArt!.range(of:"http") != nil{
            currentAlbumArt.kf.setImage(with: URL(string: currentTrackInfo.albumArt!), placeholder: UIImage(named: "background"), options: [.transition(.fade(0.2))])
        } else {
            LastFmManager.sharedInstance.getAlbumArt(artist: currentTrackInfo.artist!, album: currentTrackInfo.album!, completionHandler: { (albumUrl) in
                if let albumUrl = albumUrl {
                    DispatchQueue.main.async {
                        self.currentAlbumArt.kf.setImage(with: URL(string: albumUrl), placeholder: UIImage(named: "background"), options: [.transition(.fade(0.2))])
                    }
                }
            })
        }
        
        if currentTrackInfo.service! == "spop" {
            spotifyTrack.isHidden = false
        }
        
        self.getPlayerStatus()
    }
    
    func getPlayerStatus() {
        if let status = currentTrackInfo.status {
            switch status {
            case "play":
                startTimer()
                self.playButton.setImage(UIImage(named: "pause"), for: UIControlState.normal)
            case "pause":
                stopTimer()
                self.playButton.setImage(UIImage(named: "play"), for: UIControlState.normal)
            case "stop":
                stopTimer()
                self.playButton.setImage(UIImage(named: "play"), for: UIControlState.normal)
            default:
                stopTimer()
                self.playButton.setImage(UIImage(named: "stop"), for: UIControlState.normal)
            }
        }
        
        if let repetition = currentTrackInfo.repetition {
            switch repetition {
            case "1": self.repeatButton.setImage(UIImage(named: "repeatOn"), for: UIControlState.normal)
            case "0": self.repeatButton.setImage(UIImage(named: "repeatOff"), for: UIControlState.normal)
            default:self.repeatButton.setImage(UIImage(named: "repeatOff"), for: UIControlState.normal)
            }
        }
        
        if let shuffle = currentTrackInfo.shuffle {
            switch shuffle {
            case "1": self.shuffleButton.setImage(UIImage(named: "shuffleOn"), for: UIControlState.normal)
            case "0": self.shuffleButton.setImage(UIImage(named: "shuffleOff"), for: UIControlState.normal)
            default:self.shuffleButton.setImage(UIImage(named: "shuffleOff"), for: UIControlState.normal)
            }
        }
    }
    
    func timeFormatted(totalSeconds: Int) -> String {
        let seconds: Int = totalSeconds % 60
        let minutes: Int = (totalSeconds / 60) % 60
        let hours: Int = totalSeconds / 3600
        if hours == 0 {
            return String(format: "%02d:%02d", minutes, seconds)
        } else {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        }
    }
    
    func startTimer() {
        timer.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateSeek), userInfo:nil, repeats: true)
    }
    
    func stopTimer() {
        timer.invalidate()
        seekValue.text = timeFormatted(totalSeconds: counter/1000)
    }
    
    func updateSeek() {
        counter += 1000
        seekValue.text = timeFormatted(totalSeconds: counter/1000)
        
        let percentage = Float(counter) / (Float(trackDuration) * 1000)
        currentProgress.setProgress(percentage, animated: true)
    }
}

extension UIView {
    
    func makeCircle() {
        self.layer.cornerRadius = self.frame.size.width/2
        self.clipsToBounds = true
    }
}
