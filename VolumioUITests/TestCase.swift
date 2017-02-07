//
//  TestCase.swift
//  VolumioUITests
//
//  Created by Michael Baumgärtner on 07.02.17.
//  Copyright © 2017 Federico Sintucci. All rights reserved.
//

import XCTest

class TestCase: XCTestCase {
    
    lazy var app: XCUIApplication = {
        return XCUIApplication()
    }()
    
    override func setUp() {
        super.setUp()
        
        continueAfterFailure = false
    }

    /// Waits for the specified element to appear.
    func waitFor(element: XCUIElement) {
        expectation(
            for: NSPredicate.init(format: "exists == 1"),
            evaluatedWith: element,
            handler: nil
        )
        waitForExpectations(timeout: 3, handler: nil)
    }
    

}
