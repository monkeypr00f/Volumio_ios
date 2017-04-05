//
//  LaunchTests.swift
//  VolumioUITests
//
//  Created by Michael Baumgärtner on 07.02.17.
//  Copyright © 2017 Federico Sintucci. All rights reserved.
//

import XCTest

class LaunchTests: TestCase {
    
    override func setUp() {
        super.setUp()
        
        app.launchArguments.append("reset-user-defaults")
        app.launch()
    }
    
    func testLaunch() {
        // first view should be Playback view
        // check for navigation item title (not visible, therefore not localized)
        XCTAssertEqual(app.navigationBars.element.identifier, "Playback")

        // this is the SearchVolumio view’s close button
        let searchVolumioCloseButton = app.buttons["search-volumio-close"]

        // wait for SearchVolumio view’s close button to appear
        waitFor(element: searchVolumioCloseButton)

        // close the SearchVolumio view by tapping its close button
        searchVolumioCloseButton.tap()
        
        // this is the Playback’s view play button
        let playButton = app.buttons["play"]

        // wait for Playback view’s play button to appear
        waitFor(element: playButton)
        
        // ensure the Playback’s view blur overlay is visible
        let blurOverlay = app.otherElements["blur-overlay"]
        XCTAssertTrue(blurOverlay.exists)
    }
    
    func testLaunchAndConnect() {
        XCTAssertEqual(app.navigationBars.element.identifier, "Playback")
        
        let searchVolumioCloseButton = app.buttons["search-volumio-close"]
        waitFor(element: searchVolumioCloseButton)

        // tap to connect - this assumes a running Volumio player named "volumio"
        app.tables.staticTexts["volumio"].tap()
        
        let playButton = app.buttons["play"]
        waitFor(element: playButton)
        
        // ensure the Playback’s view blur overlay will eventually disappear
        let blurOverlay = app.otherElements["blur-overlay"]
        waitFor(element: blurOverlay, existance: false)
    }
    
}
