//
//  QueueActionsViewController.swift
//  Volumio-iOS
//
//  Created by Federico Sintucci on 27/10/16.
//  Copyright © 2016 Federico Sintucci. All rights reserved.
//

import UIKit

class QueueActionsViewController: UIViewController {
    
    var track : TrackObject!
    
    @IBOutlet weak var repeatState: UIButton!
    @IBOutlet weak var shuffleState: UIButton!
    @IBOutlet weak var consumeState: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("currentTrack"), object: nil, queue: nil, using: { notification in
            if let playing = SocketIOManager.sharedInstance.currentTrack {
                self.track = playing
                self.checkToggles()
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func checkToggles() {
        
        if let track = track {
            if let repetition = track.repetition {
                switch repetition {
                case 1: self.repeatState.setImage(UIImage(named: "repeatOn"), for: UIControlState.normal)
                default: self.repeatState.setImage(UIImage(named: "repeatOff"), for: UIControlState.normal)
                }
            }

            if let shuffle = track.shuffle {
                switch shuffle {
                case 1: self.shuffleState.setImage(UIImage(named: "shuffleOn"), for: UIControlState.normal)
                default: self.shuffleState.setImage(UIImage(named: "shuffleOff"), for: UIControlState.normal)
                }
            }

            if let consume = track.consume {
                switch consume {
                case 1: self.consumeState.setImage(UIImage(named: "consumeOn"), for: UIControlState.normal)
                default: self.consumeState.setImage(UIImage(named: "consumeOff"), for: UIControlState.normal)
                }
            }
        }
    }
    
    @IBAction func repeatToggle(_ sender: UIButton) {
        if let repetition = track.repetition {
            switch repetition {
            case 0: SocketIOManager.sharedInstance.toggleRepeat(value: 1)
            default: SocketIOManager.sharedInstance.toggleRepeat(value: 0)
            }
        } else {
            SocketIOManager.sharedInstance.toggleRepeat(value: 1)
        }
    }
    
    @IBAction func shuffleToggle(_ sender: UIButton) {
        if let shuffle = track.shuffle {
            switch shuffle {
            case 0: SocketIOManager.sharedInstance.toggleRandom(value: 1)
            default: SocketIOManager.sharedInstance.toggleRandom(value: 0)
            }
        } else {
            SocketIOManager.sharedInstance.toggleRandom(value: 1)
        }
    }

    @IBAction func consumeToggle(_ sender: UIButton) {
        if let consume = track.consume {
            switch consume {
            case 0: SocketIOManager.sharedInstance.toggleConsume(value: 1)
            default: SocketIOManager.sharedInstance.toggleConsume(value: 0)
            }
        } else {
            SocketIOManager.sharedInstance.toggleConsume(value: 1)
        }
    }
    
    @IBAction func clearButton(_ sender: UIButton) {
        SocketIOManager.sharedInstance.clearQueue()
    }
    
}
