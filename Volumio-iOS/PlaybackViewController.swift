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
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var currentTrackInformations: UIStackView!
    @IBOutlet weak var currentTrackActions: UIStackView!
    @IBOutlet weak var notificationBanner: UIView!
    
    var counter: Int = 0
    var trackDuration: Int = 0
    var currentTrackInfo:TrackObject!
    var timer = Timer()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let logo = UIImage(named: "logo")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
        
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()

        NotificationCenter.default.addObserver(forName: NSNotification.Name("currentTrack"), object: nil, queue: nil, using: { notification in
            self.getCurrentTrackInfo(empty: false)
        })
        
        NotificationCenter.default.addObserver(self, selector: #selector(getCurrentTrackInfo), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("clearQueue"), object: nil, queue: nil, using: { notification in
            self.getCurrentTrackInfo(empty: true )
        })
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("disconnected"), object: nil, queue: nil, using: { notification in
            self.notificationBanner.isHidden = false
        })
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
    
    func getCurrentTrackInfo(empty:Bool) {
        
        if let currentTrackInfo = SocketIOManager.sharedInstance.currentTrack {
            
            if let title = currentTrackInfo.title, title != "" {
                currentTitle.text = title
            }
            
            if let album = currentTrackInfo.album {
                currentAlbum.text = album
            }
            
            if let artist = currentTrackInfo.artist {
                currentArtist.text = artist
            }
            
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
            
            if let albumArt = currentTrackInfo.albumArt {
            
                if albumArt.range(of:"http") != nil{
                    currentAlbumArt.kf.setImage(with: URL(string: albumArt), placeholder: UIImage(named: "background"), options: [.transition(.fade(0.2))])
                } else {
                    if let artist = currentTrackInfo.artist, let album = currentTrackInfo.album {
                        LastFmManager.sharedInstance.getAlbumArt(artist: artist, album: album, completionHandler: { (albumUrl) in
                            if let albumUrl = albumUrl {
                                DispatchQueue.main.async {
                                    self.currentAlbumArt.kf.setImage(with: URL(string: albumUrl), placeholder: UIImage(named: "background"), options: [.transition(.fade(0.2))])
                                }
                            }
                        })
                    }
                }
            } else {
                currentAlbumArt.image = UIImage(named: "background")
            }
            
            if currentTrackInfo.service! == "spop" {
                spotifyTrack.isHidden = false
            }
            
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
                case 1: self.repeatButton.setImage(UIImage(named: "repeatOn"), for: UIControlState.normal)
                default:self.repeatButton.setImage(UIImage(named: "repeatOff"), for: UIControlState.normal)
                }
            }
            
            if let shuffle = currentTrackInfo.shuffle {
                switch shuffle {
                case 1: self.shuffleButton.setImage(UIImage(named: "shuffleOn"), for: UIControlState.normal)
                default:self.shuffleButton.setImage(UIImage(named: "shuffleOff"), for: UIControlState.normal)
                }
            }
            
            toggleInfo()
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
    
    func toggleInfo() {
        
        if let currentTrackInfo = SocketIOManager.sharedInstance.currentTrack {
            if let title = currentTrackInfo.title, title != "" {
                activityIndicator.isHidden = true
                activityIndicator.stopAnimating()
                currentTrackInformations.isHidden = false
                currentTrackActions.isHidden = false
                
            } else {
                activityIndicator.isHidden = false
                activityIndicator.startAnimating()
                currentTrackInformations.isHidden = true
                currentTrackActions.isHidden = true
            }
        }
    }
    
    @IBAction func pressPlay(_ sender: UIButton) {
        
        if let currentTrackInfo = SocketIOManager.sharedInstance.currentTrack {
            switch currentTrackInfo.status! {
            case "play":
                SocketIOManager.sharedInstance.doAction(action: "pause")
            case "pause":
                SocketIOManager.sharedInstance.doAction(action: "play")
            case "stop":
                SocketIOManager.sharedInstance.doAction(action: "play")
            default:
                SocketIOManager.sharedInstance.doAction(action: "stop")
            }
            getCurrentTrackInfo(empty: false)
        }
    }
    
    @IBAction func pressPrevious(_ sender: UIButton) {
        SocketIOManager.sharedInstance.doAction(action: "prev")
    }
    
    @IBAction func pressNext(_ sender: UIButton) {
        SocketIOManager.sharedInstance.doAction(action: "next")
    }
    
    @IBAction func pressVolumeUp(_ sender: UIButton) {
        if let currentTrackInfo = SocketIOManager.sharedInstance.currentTrack {
            if var volume = currentTrackInfo.volume {
                if volume < 100 {
                    volume += 5
                    currentVolume.text = "\(volume)"
                    SocketIOManager.sharedInstance.setVolume(value: volume)
                }
            }
        }
    }
    
    @IBAction func pressVolumeDown(_ sender: UIButton) {
        if let currentTrackInfo = SocketIOManager.sharedInstance.currentTrack {
            if var volume = currentTrackInfo.volume {
                if volume > 0 {
                    volume -= 5
                    currentVolume.text = "\(volume)"
                    SocketIOManager.sharedInstance.setVolume(value: volume)
                }
            }
        }
    }
    
    @IBAction func toggleRepeat(_ sender: UIButton) {
        if let repetition = SocketIOManager.sharedInstance.currentTrack?.repetition {
            switch repetition {
            case 1: SocketIOManager.sharedInstance.toggleRepeat(value: 0)
            default: SocketIOManager.sharedInstance.toggleRepeat(value: 1)
            }
        } else {
            SocketIOManager.sharedInstance.toggleRepeat(value: 1)
        }
    }
    
    @IBAction func toggleShuffle(_ sender: UIButton) {
        if let shuffle = SocketIOManager.sharedInstance.currentTrack?.shuffle {
            switch shuffle {
            case 1: SocketIOManager.sharedInstance.toggleRandom(value: 0)
            default: SocketIOManager.sharedInstance.toggleRandom(value: 1)
            }
        } else {
            SocketIOManager.sharedInstance.toggleRandom(value: 1)
        }
    }

    @IBAction func tapOnNotificationBanner(_ sender: UIButton) {
        SocketIOManager.sharedInstance.reConnect()
        notificationBanner.isHidden = true
        currentTrackInformations.isHidden = true
        currentTrackActions.isHidden = true
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
}
