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
        
        sleep(1)
    }

    /// Waits for the specified element to appear or disappear.
    func waitFor(element: XCUIElement, existance: Bool = true) {
        let predicate = NSPredicate(
            format: "exists == \(existance ? "1" : "0")"
        )
        expectation(for: predicate, evaluatedWith: element, handler: nil)
        waitForExpectations(timeout: 3, handler: nil)
        XCTAssertEqual(existance, element.exists)
    }

}
