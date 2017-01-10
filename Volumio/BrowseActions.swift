//
//  BrowseActions.swift
//  Volumio
//
//  Created by Federico Sintucci on 23/11/16.
//  Copyright © 2016 Federico Sintucci. All rights reserved.
//

import UIKit

protocol BrowseActionsDelegate: class {
    func browseAddAndPlay()
    func browseAddToQueue()
    func browseClearAndPlay()
}

class BrowseActions: UIView {
    
    @IBOutlet weak var view: UIView!
    weak var delegate: BrowseActionsDelegate?

    @IBOutlet weak var addToQueueLabel: UILabel!
    @IBOutlet weak var addAndPlayLabel: UILabel!
    @IBOutlet weak var clearAndPlayLabel: UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    private func initialize() {
        UINib(nibName: "BrowseActions", bundle: nil).instantiate(withOwner: self, options: nil)
        addSubview(view)
        view.frame = self.bounds
        
        // L18N
        addToQueueLabel.text = NSLocalizedString("BROWSE_ADD_TO_QUEUE",
            comment: "add to queue label"
        )
        addAndPlayLabel.text = NSLocalizedString("BROWSE_ADD_TO_QUEUE_AND_PLAY",
            comment: "add to queue and play label"
        )
        clearAndPlayLabel.text = NSLocalizedString("BROWSE_CLEAR_AND_ADD_TO_QUEUE_AND_PLAY",
            comment: "set as queue and play label"
        )
    }
    
    
    @IBAction func didAddAndPlay(_ sender: Any) {
        delegate?.browseAddAndPlay()
    }
    
    @IBAction func didAddToQueue(_ sender: Any) {
        delegate?.browseAddToQueue()
    }
    
    @IBAction func didClearAndPlay(_ sender: Any) {
        delegate?.browseClearAndPlay()
    }
    
}
