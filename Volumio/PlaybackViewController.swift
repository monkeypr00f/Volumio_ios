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
    
    var currentTrack: TrackObject? {
        didSet {
            updateCurrentTrackInfo()
        }
    }
    
    var timer = Timer()
    
    let dropper = Dropper(width: 375, height: 200)
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        VolumioIOManager.shared.getState()
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
            selector: #selector(updateCurrentTrackInfo),
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
    
    func updateCurrentTrackInfo() {
        guard let currentTrack = currentTrack else { return }

        // FIXME: Update only ui elements which content has changed

        currentTitle.text = currentTrack.localizedTitle
        currentArtist.text = currentTrack.localizedArtist
        currentAlbum.text = currentTrack.localizedAlbum
        
        if let title = currentTrack.title, !title.isEmpty {
            
            if let volume = currentTrack.volume {
                sliderVolume.value = Float(volume)
            } else {
                VolumioIOManager.shared.setVolume(value: 5)
            }
            
            if let duration = currentTrack.duration {
                trackDuration = duration
                currentDuration.text = timeFormatted(totalSeconds: duration)
                if let seek = currentTrack.seek {
                    counter = seek
                    seekValue.text = timeFormatted(totalSeconds: counter/1000)
                    
                    let percentage = Float(counter) / (Float(trackDuration) * 1000)
                    currentProgress.setProgress(percentage, animated: true)
                }
            }
            
            if let albumArt = currentTrack.albumArt {
            
                if albumArt.range(of:"http") != nil{
                    currentAlbumArt.kf.setImage(with: URL(string: albumArt), placeholder: UIImage(named: "background"), options: [.transition(.fade(0.2))])
                } else {
                    if let artist = currentTrack.artist, let album = currentTrack.album {
                        // FIXME: this is hammering last.fm because this method is called on every state change of Volumio
                        LastFMService.shared.albumGetImageURL(artist: artist, album: album, completion: { (albumUrl) in
                            DispatchQueue.main.async {
                                self.currentAlbumArt.kf.setImage(with:albumUrl, placeholder: UIImage(named: "background"), options: [.transition(.fade(0.2))])
                            }
                        })
                    }
                }
            } else {
                currentAlbumArt.image = UIImage(named: "background")
            }
            
            if let service = currentTrack.service {
                
                if service == "spop" {
                    spotifyTrack.isHidden = false
                }
            }
            
            if let status = currentTrack.status {
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
            
            if let repetition = currentTrack.repetition {
                switch repetition {
                case 1: repeatButton.alpha = 1
                default: repeatButton.alpha = 0.3
                }
            } else {
                repeatButton.alpha = 0.3
            }
            
            if let shuffle = currentTrack.shuffle {
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
    
    @IBAction func pressPlay(_ sender: UIButton) {
        guard let currentTrack = VolumioIOManager.shared.currentTrack else { return }
        
        switch currentTrack.status {
        case .some("play"):
            VolumioIOManager.shared.pause()
        case .some("pause"):
            VolumioIOManager.shared.play()
        case .some("stop"):
            VolumioIOManager.shared.play()
        default:
            VolumioIOManager.shared.stop()
        }
    }
    
    @IBAction func pressPrevious(_ sender: UIButton) {
        VolumioIOManager.shared.playPrevious()
    }
    
    @IBAction func pressNext(_ sender: UIButton) {
        VolumioIOManager.shared.playNext()
    }
    
    @IBAction func toggleRepeat(_ sender: UIButton) {
        if let repetition = VolumioIOManager.shared.currentTrack?.repetition {
            switch repetition {
            case 1: VolumioIOManager.shared.toggleRepeat(value: 0)
            default: VolumioIOManager.shared.toggleRepeat(value: 1)
            }
        } else {
            VolumioIOManager.shared.toggleRepeat(value: 1)
        }
    }
    
    @IBAction func toggleShuffle(_ sender: UIButton) {
        if let shuffle = VolumioIOManager.shared.currentTrack?.shuffle {
            switch shuffle {
            case 1: VolumioIOManager.shared.toggleRandom(value: 0)
            default: VolumioIOManager.shared.toggleRandom(value: 1)
            }
        } else {
            VolumioIOManager.shared.toggleRandom(value: 1)
        }
    }
    
    @IBAction func volumeDown(_ sender: UIButton) {
        guard let volume = currentTrack?.volume else { return }

        if volume > 0 {
            VolumioIOManager.shared.setVolume(value: volume - 1)
        }
    }
    
    @IBAction func volumeUp(_ sender: UIButton) {
        guard let volume = currentTrack?.volume else { return }
        
        if volume < 100 {
            VolumioIOManager.shared.setVolume(value: volume + 1)
        }
    }
    
    @IBAction func sliderVolume(_ sender: UISlider) {
        let volume = Int(sender.value)
        VolumioIOManager.shared.setVolume(value: volume)
    }
    
    @IBAction func reloadButton(_ sender: UIBarButtonItem) {
        clearAllNotice()
        pleaseWait()
        VolumioIOManager.shared.connectDefault()
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
