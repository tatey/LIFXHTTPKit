//
//  Created by Tate Johnson on 14/06/2015.
//  Copyright (c) 2015 Tate Johnson. All rights reserved.
//

import XCTest
import LIFXHTTPKit

class LightTargetTests: XCTestCase {
	func testObserverIsInvokedAfterStateChange() {
		let expectation = expectationWithDescription("observer")
		let client = Client(accessToken: Secrets.accessToken)
		let lightTarget = client.allLightTarget()
		lightTarget.addObserver {
			XCTAssertTrue(lightTarget.count > 0, "expected there to be at least one light")
			expectation.fulfill()
		}
		client.fetch()
		waitForExpectationsWithTimeout(3.0, handler: nil)
	}

	func testSetPowerOnSucess() {
		let expectation = expectationWithDescription("setPower")
		let client = Client(accessToken: Secrets.accessToken)
		client.fetch { (error) in
			let lightTarget = client.allLightTarget().toLightTargets().first!
			let power = !lightTarget.power
			lightTarget.setPower(power, duration: 0.0) { (results, error) in
				XCTAssertNil(error, "expected error to be nil")
				XCTAssertEqual(power, lightTarget.power, "expected light target's power to be given power after completion")
				expectation.fulfill()
			}
			XCTAssertEqual(power, lightTarget.power, "expected light target's power to be given power before completion")
		}
		waitForExpectationsWithTimeout(3.0, handler: nil)
	}

	func testSetBrightnessOnSuccess() {
		let expectation = expectationWithDescription("setBrightness")
		let client = Client(accessToken: Secrets.accessToken)
		client.fetch { (error) in
			let lightTarget = client.allLightTarget().toLightTargets().first!
			let brightness = 0.75
			lightTarget.setBrightness(brightness, duration: 0.0) { (results, error) in
				XCTAssertNil(error, "expected error to be nil")
				XCTAssertEqual(brightness, lightTarget.brightness, "expected light target's brightness to be given brightness after completion")
				expectation.fulfill()
			}
			XCTAssertEqual(brightness, lightTarget.brightness, "expected light target's brightness to be given brightness before completion")
		}
		waitForExpectationsWithTimeout(3.0, handler: nil)
	}

	func testSetColorOnSuccess() {
		let expectation = expectationWithDescription("setColor")
		let client = Client(accessToken: Secrets.accessToken)
		client.fetch { (error) in
			let lightTarget = client.allLightTarget().toLightTargets().first!
			let color = Color(hue: 180.0, saturation: 1.0, kelvin: 3500)
			lightTarget.setColor(color, duration: 0.0) { (results, error) in
				XCTAssertNil(error, "expected error to be nil")
				XCTAssertEqual(color, lightTarget.color, "expected light target's color to be given color after completion")
				expectation.fulfill()
			}
			XCTAssertEqual(color, lightTarget.color, "expected light target's color to be given color before completion")
		}
		waitForExpectationsWithTimeout(3.0, handler: nil)
	}
}
