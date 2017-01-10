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
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    private func initialize() {
        UINib(nibName: "PlaylistActions", bundle: nil).instantiate(withOwner: self, options: nil)
        addSubview(view)
        view.frame = self.bounds

        // L18N
        playLabel.text = NSLocalizedString("BROWSE_PLAY_PLAYLIST",
            comment: "play playlist button label"
        )
        editLabel.text = NSLocalizedString("BROWSE_EDIT_PLAYLIST",
            comment: "edit playlist button label"
        )
    }
    
    
    @IBAction func didAddAndPlay(_ sender: Any) {
        delegate?.playlistAddAndPlay()
    }
    
    @IBAction func didEdit(_ sender: Any) {
        delegate?.playlistEdit()
    }

}
