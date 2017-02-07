//
//  LaunchConnectedTests.swift
//  VolumioUITests
//
//  Created by Michael Baumgärtner on 07.02.17.
//  Copyright © 2017 Federico Sintucci. All rights reserved.
//

import XCTest

class LaunchConnectedTests: TestCase {
    
    override func setUp() {
        super.setUp()
        
        // use default user defaults to connect - this assumes a running Volumio player accessible via http://volumio.local:3000
        app.launchArguments.append("default-user-defaults")
        app.launch()
    }
    
    func testLaunchConnected() {
        XCTAssertEqual(app.navigationBars.element.identifier, "Playback")
        
        // ensure the Playback’s view blur overlay will eventually disappear
        let blurOverlay = app.otherElements["blur-overlay"]
        waitFor(element: blurOverlay, existance: false)
    }
    
}
