//
//  VolumioTableViewController.swift
//  Volumio
//
//  Created by Michael Baumgärtner on 29.01.17.
//  Copyright © 2017 Federico Sintucci. All rights reserved.
//

import UIKit

/**
 This class extends `UITableViewcontroller` to handle a connection to a volumio server.
 - Note: Because this has to be implemented via subclassing, this code is duplicated across serveral view controller subtypes. See `VolumioViewController`, `VolumioFormViewController`.
 */
class VolumioTableViewController: UITableViewController, VolumioController, ObservesNotifications {
    
    var observers: [AnyObject] = []
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self._viewWillAppear()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self._viewDidAppear()
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self._viewDidDisappear()
        super.viewDidDisappear(animated)
    }
    
    // if a subclass wants to act on a connected event, it can override this method (but it has to call this super methd)
    func volumioConnected() {
        self._volumioConnected()
    }
    
    // if a subclass wants to act on a disconnected event, it can override this method (but it has to call this super methd)
    func volumioDisconnected() {
        self._volumioDisconnected()
    }
    
}
