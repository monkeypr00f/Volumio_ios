//
//  QueueActions.swift
//  Volumio
//
//  Created by Federico Sintucci on 23/11/16.
//  Copyright © 2016 Federico Sintucci. All rights reserved.
//

import UIKit

protocol QueueActionsDelegate: class {
    func didRepeat()
    func didShuffle()
    func didConsume()
    func didClear()
}

class QueueActions: UIView {

    @IBOutlet weak fileprivate var view: UIView!

    weak var delegate: QueueActionsDelegate?

    @IBOutlet weak fileprivate var repeatState: UIButton!
    @IBOutlet weak fileprivate var shuffleState: UIButton!
    @IBOutlet weak fileprivate var consumeState: UIButton!

    @IBOutlet weak fileprivate var repeatLabel: UILabel!
    @IBOutlet weak fileprivate var shuffleLabel: UILabel!
    @IBOutlet weak fileprivate var consumeLabel: UILabel!
    @IBOutlet weak fileprivate var clearLabel: UILabel!

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
        UINib(nibName: "QueueActions", bundle: nil).instantiate(withOwner: self, options: nil)
        addSubview(view)
        view.frame = self.bounds

        repeatState.alpha = 0.3
        shuffleState.alpha = 0.3
        consumeState.alpha = 0.3
    }

    @IBAction func didPressRepeat(_ sender: Any) {
        delegate?.didRepeat()
    }

    @IBAction func didPressShuffle(_ sender: Any) {
        delegate?.didShuffle()
    }

    @IBAction func didPressConsume(_ sender: Any) {
        delegate?.didConsume()
    }

    @IBAction func didPressClear(_ sender: Any) {
        delegate?.didClear()
    }

    func update(for track: TrackObject) {
        if let repetition = track.repetition {
            switch repetition {
            case 1: repeatState.alpha = 1
            default: repeatState.alpha = 0.3
            }
        }

        if let shuffle = track.shuffle {
            switch shuffle {
            case 1: shuffleState.alpha = 1
            default: shuffleState.alpha = 0.3
            }
        }

        if let consume = track.consume {
            switch consume {
            case 1: consumeState.alpha = 1
            default: consumeState.alpha = 0.3
            }
        }
    }

}

// MARK: Localization

extension QueueActions {

    fileprivate func localize() {
        repeatLabel.text = NSLocalizedString("QUEUE_REPEAT",
            comment: "[toggle](short) queue repeat"
        )
        shuffleLabel.text = NSLocalizedString("QUEUE_SHUFFLE",
            comment: "[toggle](short) queue shuffle"
        )
        consumeLabel.text = NSLocalizedString("QUEUE_CONSUME",
            comment: "[toggle](short) queue consume"
        )
        clearLabel.text = NSLocalizedString("QUEUE_CLEAR",
            comment: "[trigger](short) queue clear"
        )
    }

}
