//
//  SnapshotsTests.swift
//  Volumio
//
//  Created by Michael Baumgärtner on 07.02.17.
//  Copyright © 2017 Federico Sintucci. All rights reserved.
//

import Foundation

import XCTest

class SnapshotsTests: TestCase {
    
    override func setUp() {
        super.setUp()
        
        setupSnapshot(app)
        
        app.launchArguments.append("reset-user-defaults")
        app.launch()
    }
    
    /// - SeeAlso: LaunchTests
    func testCapture() {
        let searchVolumioCloseButton = app.buttons["search-volumio-close"]
        waitFor(element: searchVolumioCloseButton)

        snapshot("00SearchVolumio")
        
        app.tables.staticTexts["volumio"].tap()
        
        let playButton = app.buttons["play"]
        waitFor(element: playButton)
        
        let blurOverlay = app.otherElements["blur-overlay"]
        waitFor(element: blurOverlay, existance: false)
        
        snapshot("01Playback")
        
        app.tabBars.buttons["Queue"].tap()

        snapshot("02Queue")

        app.tabBars.buttons["Browse"].tap()

        snapshot("03Browse")

        app.tabBars.buttons["Settings"].tap()

        snapshot("04Settings")
    }

}
