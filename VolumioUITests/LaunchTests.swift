//
//  LaunchTests.swift
//  VolumioUITests
//
//  Created by Michael Baumgärtner on 07.02.17.
//  Copyright © 2017 Federico Sintucci. All rights reserved.
//

import XCTest

class LaunchTests: XCTestCase {
    
    lazy var app: XCUIApplication = {
        return XCUIApplication()
    }()
    
    override func setUp() {
        super.setUp()
        
        continueAfterFailure = false

        app.launchArguments.append("reset-user-defaults")
        app.launch()
    }
    
    func waitFor(element: XCUIElement) {
        expectation(
            for: NSPredicate.init(format: "exists == 1"),
            evaluatedWith: element,
            handler: nil
        )
        waitForExpectations(timeout: 3, handler: nil)
    }
    
    func testLaunch() {
        // first view should be Playback view
        // check for navigation item title (not visible, therefor not localized)
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
        expectation(
            for: NSPredicate.init(format: "exists == 0"),
            evaluatedWith: blurOverlay,
            handler: nil
        )
        waitForExpectations(timeout: 3, handler: nil)
        XCTAssertFalse(blurOverlay.exists)
    }
    
}
