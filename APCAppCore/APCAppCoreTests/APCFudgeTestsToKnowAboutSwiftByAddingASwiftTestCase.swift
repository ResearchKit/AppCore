//
//  APCFudgeTestsToKnowAboutSwiftByAddingASwiftTestCase.swift
//  APCAppCore
//
//  Created by Erin Mounts on 2/12/16.
//  Copyright © 2016 Sage Bionetworks, Inc. All rights reserved.
//

import XCTest

// ResearchKit uses these, and if we don't import them the tests crash on load due to missing Swift dylibs
// (Apple PLEASE fix this...)
import CoreAudio
import CoreLocation

class APCFudgeTestsToKnowAboutSwiftByAddingASwiftTestCase: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }

}
