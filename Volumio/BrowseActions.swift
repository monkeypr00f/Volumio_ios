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

    @IBOutlet weak private var view: UIView!

    @IBOutlet weak fileprivate var addAndPlayLabel: UILabel!
    @IBOutlet weak fileprivate var addToQueueLabel: UILabel!
    @IBOutlet weak fileprivate var clearAndPlayLabel: UILabel!

    weak var delegate: BrowseActionsDelegate?

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
        UINib(nibName: "BrowseActions", bundle: nil).instantiate(withOwner: self, options: nil)
        addSubview(view)
        view.frame = self.bounds
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

// MARK: - Localization

extension BrowseActions {

    fileprivate func localize() {
        addAndPlayLabel.text = NSLocalizedString("BROWSE_ADD_TO_QUEUE_AND_PLAY_ALL",
            comment: "[trigger](short) add items to queue and start playing"
        )
        addToQueueLabel.text = NSLocalizedString("BROWSE_ADD_TO_QUEUE_ALL",
            comment: "[trigger](short) add items to queue"
        )
        clearAndPlayLabel.text = NSLocalizedString("BROWSE_CLEAR_AND_ADD_TO_QUEUE_AND_PLAY_ALL",
            comment: "[trigger](short) clear queue, add items and start playing"
        )
    }

}
