//
//  PlaybackViewController.swift
//  Volumio
//
//  Created by Federico Sintucci on 20/09/16.
//  Copyright © 2016 Federico Sintucci. All rights reserved.
//

import UIKit

import Dropper

/**
 Controller for playback view. Inherits automatic connection handling from `VolumioViewController`.
 */
class PlaybackViewController: VolumioViewController {
    
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
    var currentTrack: TrackObject?
    var timer = Timer()
    
    let dropper = Dropper(width: 375, height: 200)
    
    // MARK: - View Callbacks
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let logo = UIImage(named: "logo")
        let imageView = UIImageView(image:logo)
        navigationItem.titleView = imageView
        
        repeatButton.alpha = 0.3
        shuffleButton.alpha = 0.3
    }

    override func viewWillLayoutSubviews() {
        innerRing.makeCircle()
        outerRing.makeCircle()
        
        currentProgress.transform = CGAffineTransform(scaleX: 1.0, y: 3.0)

        playerViewShadow.layer.shadowOffset = CGSize.zero
        playerViewShadow.layer.shadowOpacity = 1
        playerViewShadow.layer.shadowRadius = 3
        
        super.viewWillLayoutSubviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        registerObserver(forName: .UIApplicationWillEnterForeground) { (notification) in
            self.clearAllNotice()

            self.update()
        }
        registerObserver(forName: .currentTrack) { [unowned self] (notification) in
            self.clearAllNotice()

            guard let track = notification.object as? TrackObject
                else { return }
            self.currentTrack = track
            self.update()
        }
        registerObserver(forName: .addedToPlaylist) { [unowned self] (notification) in
            self.clearAllNotice()
            
            guard let object = notification.object
                else { return }
            self.notice(self.localizedAddedToPlaylistNotice(name: String(describing: object)))
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        pleaseWait()
        
        super.viewDidAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        clearAllNotice()
    }
    
    // MARK: - View Update

    func update() {
        let didUpdateTrackInfo = updateTrackInfo(for: currentTrack)

        blurOverlay.isHidden = didUpdateTrackInfo
        
        updatePlaybackControls(for: currentTrack)
    }
    
    @discardableResult
    func updateTrackInfo(for track: TrackObject?) -> Bool {
        guard let track = track else { return false }

        guard let title = track.title, !title.isEmpty else { return false }
        
        currentTitle.text = track.localizedTitle
        currentArtist.text = track.localizedArtist
        currentAlbum.text = track.localizedAlbum
        
        if let volume = track.volume {
            sliderVolume.value = Float(volume)
        } else {
            // why this?
            VolumioIOManager.shared.setVolume(value: 5)
        }
        
        if let duration = track.duration {
            trackDuration = duration
            currentDuration.text = timeFormatted(totalSeconds: duration)
            if let seek = track.seek {
                counter = seek
                seekValue.text = timeFormatted(totalSeconds: counter/1000)
                
                let percentage = Float(counter) / (Float(trackDuration) * 1000)
                currentProgress.setProgress(percentage, animated: true)
            }
        }
        
        if let albumArt = track.albumArt {
            if albumArt.range(of:"http") != nil{
                currentAlbumArt.kf.setImage(with: URL(string: albumArt), placeholder: UIImage(named: "background"), options: [.transition(.fade(0.2))])
            } else {
                if let artist = track.artist, let album = track.album {
                    LastFMService.shared.albumGetImageURL(artist: artist, album: album, completion: { (albumUrl) in
                        if let albumUrl = albumUrl {
                            DispatchQueue.main.async {
                                self.currentAlbumArt.kf.setImage(with:albumUrl, placeholder: UIImage(named: "background"), options: [.transition(.fade(0.2))])
                            }
                        }
                    })
                }
            }
        } else {
            currentAlbumArt.image = UIImage(named: "background")
        }
        
        if let service = track.service {
            if service == "spop" {
                spotifyTrack.isHidden = false
            }
        }
        
        return true
    }
    
    @discardableResult
    func updatePlaybackControls(for track: TrackObject?) -> Bool {
        guard let track = track
            else {
                stopTimer()
                return false
            }

        if let status = track.status {
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
        
        if let repetition = track.repetition {
            switch repetition {
            case 1:
                repeatButton.alpha = 1
            default:
                repeatButton.alpha = 0.3
            }
        } else {
            repeatButton.alpha = 0.3
        }
        
        if let shuffle = track.shuffle {
            switch shuffle {
            case 1:
                shuffleButton.alpha = 1
            default:
                shuffleButton.alpha = 0.3
            }
        } else {
            shuffleButton.alpha = 0.3
        }
        
        return true
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
    
    // MARK: - View Actions
    
    @IBAction func pressPlay(_ sender: UIButton) {
        if let currentTrackInfo = VolumioIOManager.shared.currentTrack {
            switch currentTrackInfo.status! {
            case "play":
                VolumioIOManager.shared.pause()
            case "pause":
                VolumioIOManager.shared.play()
            case "stop":
                VolumioIOManager.shared.play()
            default:
                VolumioIOManager.shared.stop()
            }
            update()
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
    
    // MARK: - Volumio Events
    
    override func volumioDisconnected() {
        super.volumioDisconnected()
        
        currentTrack = nil
        update()
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
