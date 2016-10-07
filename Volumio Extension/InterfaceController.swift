//
//  InterfaceController.swift
//  Volumio Extension
//
//  Created by Federico Sintucci on 03/10/16.
//  Copyright © 2016 Federico Sintucci. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {

    @IBOutlet var playButton: WKInterfaceButton!
    @IBOutlet var artistLable: WKInterfaceLabel!
    @IBOutlet var titleLabel: WKInterfaceLabel!
    @IBOutlet var albumLable: WKInterfaceLabel!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    @IBAction func pressPlayButton() {
    
    }
    
    @IBAction func nextButton() {
        
    }

    @IBAction func prevButton() {
        
    }
    
    @IBAction func volumeUp() {
        
    }

    @IBAction func volumeDown() {
        
    }
}
