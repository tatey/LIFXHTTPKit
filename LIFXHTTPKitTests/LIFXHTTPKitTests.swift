//
//  LIFXHTTPKitTests.swift
//  LIFXHTTPKitTests
//
//  Created by Tate Johnson on 29/05/2015.
//  Copyright (c) 2015 Tate Johnson. All rights reserved.
//

import Cocoa
import XCTest
import LIFXHTTPKit

class LIFXHTTPKitTests: XCTestCase {
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
        XCTAssert(true, "Pass")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }

	func testClient() {
		let expectation = expectationWithDescription("")
		let client = Client(accessToken: "")
		client.discover()
		let lights = client.allLights()
		lights.addObserver {
			if lights.toLights().count > 0 {
				expectation.fulfill()
			}
		}
		waitForExpectationsWithTimeout(5.0, handler: nil)
	}
}
