//
//  Created by Tate Johnson on 14/06/2015.
//  Copyright (c) 2015 Tate Johnson. All rights reserved.
//

import XCTest
import LIFXHTTPKit

class LightTargetTests: XCTestCase {
	lazy var lightTarget: LightTarget = {
		if let first = ClientHelper.sharedClient.allLightTarget().toLightTargets().first {
			return first
		} else {
			fatalError("\(__FUNCTION__): Expected at least one connected light target")
		}
	}()

	func testSetPower() {
		let expectation = expectationWithDescription("setPower")
		let newPower = !lightTarget.power
		lightTarget.setPower(newPower, duration: 0.0, completionHandler: { (results, error) in
			dispatch_async(dispatch_get_main_queue()) {
				XCTAssertNil(error, "expected error to be nil")
				XCTAssertEqual(newPower, self.lightTarget.power, "power is still new value after operation is completed")
				expectation.fulfill()
			}
		})
		XCTAssertEqual(newPower, lightTarget.power, "power is optimstically set to new value")
		waitForExpectationsWithTimeout(3.0, handler: nil)
	}

	func testSetBrightness() {
		let expectation = expectationWithDescription("setBrightness")
		let newBrightness = Double(arc4random_uniform(100)) / 100.0
		lightTarget.setBrightness(newBrightness, duration: 0.0) { (results, error) in
			dispatch_async(dispatch_get_main_queue()) {
				XCTAssertNil(error, "expected error to be nil")
				XCTAssertEqual(newBrightness, self.lightTarget.brightness, "brightness is still new value after operation is completed")
				expectation.fulfill()
			}
		}
		XCTAssertEqual(newBrightness, lightTarget.brightness, "brightness is optimistically set to new value")
		waitForExpectationsWithTimeout(3.0, handler: nil)
	}

	func testSetColor() {
		let expectation = expectationWithDescription("setColor")
		let newColor = Color.color(Double(arc4random_uniform(360)), saturation: 0.5)
		lightTarget.setColor(newColor, duration: 0.0, completionHandler: { (results, error) in
			dispatch_async(dispatch_get_main_queue()) {
				XCTAssertNil(error, "expected error to be nil")
				XCTAssertEqual(newColor.hue, self.lightTarget.color.hue, "hue is still new value after operation is completed")
				expectation.fulfill()
			}
		})
		XCTAssertEqual(newColor.hue, lightTarget.color.hue, "hue is optimsitically set to new value")
		waitForExpectationsWithTimeout(3.0, handler: nil)
	}
}
