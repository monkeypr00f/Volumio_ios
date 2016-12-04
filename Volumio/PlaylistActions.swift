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
    }
    
    
    @IBAction func didAddAndPlay(_ sender: Any) {
        delegate?.playlistAddAndPlay()
    }
    
    @IBAction func didEdit(_ sender: Any) {
        delegate?.playlistEdit()
    }

}
