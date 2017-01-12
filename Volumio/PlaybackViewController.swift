//
//  PlaybackViewController.swift
//  Volumio
//
//  Created by Federico Sintucci on 20/09/16.
//  Copyright © 2016 Federico Sintucci. All rights reserved.
//

import UIKit
import Kingfisher
import Dropper

class PlaybackViewController: UIViewController {
    
    // information block
    @IBOutlet weak var currentAlbum: UILabel!
    @IBOutlet weak var currentTitle: UILabel!
    @IBOutlet weak var currentArtist: UILabel!
    @IBOutlet weak var currentAlbumArt: UIImageView!
    @IBOutlet weak var currentAddToFavourite: UIButton!
    @IBOutlet weak var spotifyTrack: UIImageView!
    
    // actions block
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var repeatButton: UIButton!
    @IBOutlet weak var shuffleButton: UIButton!
    @IBOutlet weak var sliderVolume: UISlider!
    @IBOutlet weak var currentProgress: UIProgressView!
    @IBOutlet weak var seekValue: UILabel!
    @IBOutlet weak var currentDuration: UILabel!

    // graphic block
    @IBOutlet weak var outerRing: UIView!
    @IBOutlet weak var innerRing: UIView!
    @IBOutlet weak var playerView: UIView!
    @IBOutlet weak var playerViewShadow: UIView!
    @IBOutlet weak var dropdownSelector: UIButton!

    @IBOutlet weak var blurOverlay: UIVisualEffectView!
    
    var counter: Int = 0
    var trackDuration: Int = 0
    var currentTrack:TrackObject?
    var timer = Timer()
    
    let dropper = Dropper(width: 375, height: 200)
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        SocketIOManager.sharedInstance.getState()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let logo = UIImage(named: "logo")
        let imageView = UIImageView(image:logo)
        navigationItem.titleView = imageView
        
        registerObservers()
        
        pleaseWait()
        
        repeatButton.alpha = 0.3
        shuffleButton.alpha = 0.3
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        innerRing.makeCircle()
        outerRing.makeCircle()
        
        currentProgress.transform = CGAffineTransform(scaleX: 1.0, y: 3.0)

        playerViewShadow.layer.shadowOffset = CGSize.zero
        playerViewShadow.layer.shadowOpacity = 1
        playerViewShadow.layer.shadowRadius = 3
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        clearAllNotice()
    }
    
    private func registerObservers() {
        NotificationCenter.default.addObserver(self,
            selector: #selector(getCurrentTrackInfo),
            name: .UIApplicationWillEnterForeground,
            object: nil
        )
        NotificationCenter.default.addObserver(self,
            selector: #selector(isDisconnected(notification:)),
            name: .disconnected,
            object: nil
        )
        NotificationCenter.default.addObserver(self,
            selector: #selector(getCurrentTrack(notification:)),
            name: .currentTrack,
            object: nil
        )
        NotificationCenter.default.addObserver(self,
            selector: #selector(isOnPlaylist(notification:)),
            name: .addedToPlaylist,
            object: nil
        )
    }
    
    func isDisconnected(notification: NSNotification) {
        clearAllNotice()
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "SearchingViewController") as! SearchVolumioViewController
        self.present(controller, animated: true, completion: nil)
    }
    
    func getCurrentTrack(notification:NSNotification) {
        clearAllNotice()
        blurOverlay.isHidden = true
        currentTrack = notification.object as? TrackObject
        getCurrentTrackInfo()
    }
    
    func isOnPlaylist(notification:NSNotification) {
        clearAllNotice()
        
        guard let object = notification.object else { return }
        
        noticeTop(
            localizedAddedToPlaylistNotice(name: String(describing: object)),
            autoClear: true,
            autoClearTime: 3
        )
    }
    
    func getCurrentTrackInfo() {
        
        if let currentTrackInfo = currentTrack {
            
            if let title = currentTrackInfo.title, title != "" {
                currentTitle.text = title
                
                if let album = currentTrackInfo.album {
                    currentAlbum.text = album
                }
                
                if let artist = currentTrackInfo.artist {
                    currentArtist.text = artist
                }
                
                if let volume = currentTrackInfo.volume {
                    sliderVolume.value = Float(volume)
                } else {
                    SocketIOManager.sharedInstance.setVolume(value: 5)
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
                
                if let service = currentTrackInfo.service {
                    
                    if service == "spop" {
                        spotifyTrack.isHidden = false
                    }
                }
                
                if let status = currentTrackInfo.status {
                    switch status {
                    case "play":
                        startTimer()
                        playButton.setImage(UIImage(named: "pause"), for: UIControlState.normal)
                    case "pause":
                        stopTimer()
                        playButton.setImage(UIImage(named: "play"), for: UIControlState.normal)
                    case "stop":
                        stopTimer()
                        playButton.setImage(UIImage(named: "play"), for: UIControlState.normal)
                    default:
                        stopTimer()
                        playButton.setImage(UIImage(named: "stop"), for: UIControlState.normal)
                    }
                }
                
                if let repetition = currentTrackInfo.repetition {
                    switch repetition {
                    case 1: repeatButton.alpha = 1
                    default: repeatButton.alpha = 0.3
                    }
                } else {
                    repeatButton.alpha = 0.3
                }
                
                if let shuffle = currentTrackInfo.shuffle {
                    switch shuffle {
                    case 1: shuffleButton.alpha = 1
                    default: shuffleButton.alpha = 0.3
                    }
                } else {
                    shuffleButton.alpha = 0.3
                }
            
            } else {
                blurOverlay.isHidden = false
                
                noticeTop(localizedQueueIsEmptyNotice)
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
        timer = Timer.scheduledTimer(
            timeInterval: 1.0,
            target: self,
            selector: #selector(updateSeek),
            userInfo:nil,
            repeats: true
        )
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
    
    func sliderValueDidChanged(slider: UISlider) {
        print(slider.value)
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
            getCurrentTrackInfo()
        }
    }
    
    @IBAction func pressPrevious(_ sender: UIButton) {
        SocketIOManager.sharedInstance.doAction(action: "prev")
    }
    
    @IBAction func pressNext(_ sender: UIButton) {
        SocketIOManager.sharedInstance.doAction(action: "next")
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
    
    @IBAction func volumeDown(_ sender: UIButton) {
        guard let volume = currentTrack?.volume else { return }

        if volume > 0 {
            SocketIOManager.sharedInstance.setVolume(value: volume - 1)
        }
    }
    
    @IBAction func volumeUp(_ sender: UIButton) {
        guard let volume = currentTrack?.volume else { return }
        
        if volume < 100 {
            SocketIOManager.sharedInstance.setVolume(value: volume + 1)
        }
    }
    
    @IBAction func sliderVolume(_ sender: UISlider) {
        let volume = Int(sender.value)
        SocketIOManager.sharedInstance.setVolume(value: volume)
    }
    
    @IBAction func reloadButton(_ sender: UIBarButtonItem) {
        clearAllNotice()
        SocketIOManager.sharedInstance.reConnect()
        pleaseWait()
    }
    
    @IBAction func dropdownPressed(_ sender: UIButton) {
        if dropper.status == .hidden {
            dropper.delegate = self
            dropper.items = ["Item 1", "Item 2", "Item 3", "Item 4"] // Item displayed
            dropper.theme = Dropper.Themes.black(nil)
            dropper.showWithAnimation(0.15, options: .center, position: .top, button: dropdownSelector)
        } else {
            dropper.hideWithAnimation(0.1)
        }
    }
}

extension PlaybackViewController: DropperDelegate {
    func DropperSelectedRow(_ path: IndexPath, contents: String) {

    }
}

// MARK: - Localization

extension PlaybackViewController {
    
    fileprivate func localizedAddedToPlaylistNotice(name: String) -> String {
        return String.localizedStringWithFormat(
            localizedAddedToPlaylistNotice,
            name
        )
    }
    
    fileprivate var localizedAddedToPlaylistNotice: String {
        return NSLocalizedString("PLAYLIST_ADDED_ITEM",
                comment: "[hint](format) added item to playlist(%@)"
        )
    }
    
    fileprivate var localizedQueueIsEmptyNotice: String {
        return NSLocalizedString("PLAYBACK_QUEUE_IS_EMPTY",
                comment: "[hint] playback queue is empty")
    }
    
}
