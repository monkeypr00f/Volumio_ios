//
//  VolumioUITests.swift
//  VolumioUITests
//
//  Created by Michael Baumgärtner on 07.02.17.
//  Copyright © 2017 Federico Sintucci. All rights reserved.
//

import XCTest

class VolumioUITests: XCTestCase {
    
    lazy var app: XCUIApplication = {
        return XCUIApplication()
    }()
    
    override func setUp() {
        super.setUp()
        
        continueAfterFailure = false

        app.launchArguments.append("reset-user-defaults")
        app.launch()
    }
    
    func testLaunch() {
        // first view should be Playback view
        // check for navigation item title (not visible, therefor not localized)
        XCTAssertEqual(app.navigationBars.element.identifier, "Playback")

        // wait for SearchVolumio view to appear
        // this is the close button by its accessibilty identifier
        let closeButton = app.buttons["search-volumio-close"]
        expectation(
            for: NSPredicate.init(format: "exists == 1"),
            evaluatedWith: closeButton,
            handler: nil
        )
        waitForExpectations(timeout: 3, handler: nil)

        // close the SearchVolumio view
        closeButton.tap()
    }
    
}
