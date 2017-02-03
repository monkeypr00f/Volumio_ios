//
//  VolumioController.swift
//  Volumio
//
//  Created by Michael Baumgärtner on 29.01.17.
//  Copyright © 2017 Federico Sintucci. All rights reserved.
//

import UIKit

protocol VolumioController {
    func connectToVolumio()
    
    func volumioWillConnect()
    func volumioDidConnect()
    func volumioDidDisconnect()
}

extension VolumioController where Self: UIViewController, Self: ObservesNotifications {
    
    /// Connects to Volumio player if there is no connection yet or tries to get current state otherwise.
    func connectToVolumio() {
        if !VolumioIOManager.shared.isConnected && !VolumioIOManager.shared.isConnecting {
            volumioWillConnect()
            VolumioIOManager.shared.connectDefault()
        }
        else {
            volumioDidConnect()
        }
    }
    
    // MARK: - View Callbacks (default implementations)
    
    func _viewWillAppear() {
        registerObserver(forName: .connected) { (notification) in
            self.volumioDidConnect()
        }
        registerObserver(forName: .disconnected) { (notification) in
            self.volumioDidDisconnect()
        }
    }

    func _viewDidAppear() {
        connectToVolumio()
    }

    func _viewDidDisappear() {
        unregisterObservers()        
    }
    
    // MARK: - Volumio Callbacks (default implementations)
    
    func _volumioConnected() {
        Log.entry(self, message: "- Volumio is connected")
    }
    
    func _volumioDisconnected() {
        Log.entry(self, message: "- Volumio is disconnected")
        
        // Search for Volumio players

        let controller = UIViewController.instantiate(
            fromStoryboard: "SearchVolumio",
            withIdentifier: "SearchVolumioViewController"
        ) as! SearchVolumioViewController
        controller.finished = { [unowned self] (player) in
            controller.dismiss(animated: true, completion: nil)
            guard let player = player else { return }
            self.volumioWillConnect()
            VolumioIOManager.shared.connect(to: player, setDefault: true)
        }
        present(controller, animated: true, completion: nil)
    }
    
}
