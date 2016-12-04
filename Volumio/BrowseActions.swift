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
