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
		let lightTarget = client.allLightTarget()
		lightTarget.addObserver {
			XCTAssertTrue(lightTarget.count > 0, "expected there to be at least one light")
			expectation.fulfill()
		}
		client.fetch()
		waitForExpectationsWithTimeout(3.0, handler: nil)
	}

	func testSetPowerTurnsLightTargetOn() {
		let expectation = expectationWithDescription("setPower")
		let client = Client(accessToken: "")
		let lightTarget = client.allLightTarget()

		lightTarget.setPower(true, duration: 1.0) { (results, error) in
			XCTAssertNil(error, "expected error to be nil")
			XCTAssertTrue(lightTarget.power, "expected power to be true after completion")
			expectation.fulfill()
		}
		XCTAssertTrue(lightTarget.power, "expected power to be true before completion")
		waitForExpectationsWithTimeout(3.0, handler: nil)
	}
}
