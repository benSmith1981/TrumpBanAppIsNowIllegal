//
//  IsNowIllegalUITests.swift
//  IsNowIllegalUITests
//
//  Created by Ben Smith on 29/05/2017.
//  Copyright © 2017 Ben Smith. All rights reserved.
//

import XCTest

class IsNowIllegalUITests: XCTestCase {
    
    func testExample() {
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
        snapshot("ThisScreenNeedsScreenShots")
    }
    
}
