//
//  PlaylistActions.swift
//  Volumio
//
//  Created by Federico Sintucci on 02/12/16.
//  Copyright © 2016 Federico Sintucci. All rights reserved.
//

import UIKit

protocol PlaylistActionsDelegate: class {
    func playlistAddAndPlay()
    func playlistEdit()
}

class PlaylistActions: UIView {

    @IBOutlet weak var view: UIView!
    
    weak var delegate: PlaylistActionsDelegate?
    
    @IBOutlet weak var playLabel: UILabel!
    @IBOutlet weak var editLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
        localize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
        localize()
    }
    
    private func initialize() {
        UINib(nibName: "PlaylistActions", bundle: nil).instantiate(withOwner: self, options: nil)
        addSubview(view)
        view.frame = self.bounds
    }
    
    @IBAction func didAddAndPlay(_ sender: Any) {
        delegate?.playlistAddAndPlay()
    }
    
    @IBAction func didEdit(_ sender: Any) {
        delegate?.playlistEdit()
    }

}

// MARK: - Localization

extension PlaylistActions {
    
    fileprivate func localize() {
        playLabel.text = NSLocalizedString("BROWSE_PLAY_PLAYLIST",
            comment: "[trigger](short) play playlist"
        )
        editLabel.text = NSLocalizedString("BROWSE_EDIT_PLAYLIST",
            comment: "[trigger](short) edit playlist"
        )
    }
    
}
