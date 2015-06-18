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

	func testSetPowerTogglesPower() {
		let expectation = expectationWithDescription("setPower")
		let client = Client(accessToken: "")
		client.fetch { (error) in
			let lightTarget = client.allLightTarget().toLightTargets().first!
			let power = !lightTarget.power
			lightTarget.setPower(power, duration: 0.5) { (results, error) in
				XCTAssertNil(error, "expected error to be nil")
				XCTAssertEqual(power, lightTarget.power, "expected light target's power to be given power after completion")
				expectation.fulfill()
			}
			XCTAssertEqual(power, lightTarget.power, "expected light target's power to be given power before completion")
		}
		waitForExpectationsWithTimeout(3.0, handler: nil)
	}
}
