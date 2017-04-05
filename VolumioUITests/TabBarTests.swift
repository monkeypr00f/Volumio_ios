//
//  TabBarTests.swift
//  Volumio
//
//  Created by Michael Baumgärtner on 08.02.17.
//  Copyright © 2017 Federico Sintucci. All rights reserved.
//

import XCTest

class TabBarTests: TestCase {
    
    override func setUp() {
        super.setUp()
        
        app.launchArguments.append("default-user-defaults")
        app.launch()
    }
    
    func testTabBar() {
        XCTAssertEqual(app.navigationBars.element.identifier, "Playback")
        
        app.tabBars.buttons["Queue"].tap()
        // TODO: check if queue view is shown
        
        app.tabBars.buttons["Browse"].tap()
        // TODO: check if browse view is shown

        app.tabBars.buttons["Settings"].tap()
        // TODO: check if settings view is shown
        
        app.tabBars.buttons["Playback"].tap()
        XCTAssertEqual(app.navigationBars.element.identifier, "Playback")
    }
    
}
