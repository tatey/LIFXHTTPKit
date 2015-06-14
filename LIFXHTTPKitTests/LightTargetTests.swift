//
//  Created by Tate Johnson on 14/06/2015.
//  Copyright (c) 2015 Tate Johnson. All rights reserved.
//

import Cocoa
import XCTest
import LIFXHTTPKit

class LightTargetTests: XCTestCase {
	func testObserverIsInvokedAfterStateChange() {
		let expectation = expectationWithDescription("observer")
		let client = Client(accessToken: "")
		let lights = client.allLights()
		lights.addObserver {
			XCTAssertTrue(lights.toLights().count > 0, "expected there to be lights")
		}
		client.fetch()
		waitForExpectationsWithTimeout(3.0, handler: nil)
	}

	func testSetPowerTurnsLightTargetOn() {
		let expectation = expectationWithDescription("setPower")
		let client = Client(accessToken: "")
		let lights = client.allLights()

		lights.setPower(true, duration: 1.0) { (results, error) in
			XCTAssertNil(error, "expected error to be nil")
			XCTAssertTrue(lights.power, "expected power to be true after completion")
			expectation.fulfill()
		}
		XCTAssertTrue(lights.power, "expected power to be true before completion")
		waitForExpectationsWithTimeout(3.0, handler: nil)
	}
}
