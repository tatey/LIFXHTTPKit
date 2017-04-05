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
			fatalError("\(#function): Expected at least one connected light target")
		}
	}()
	
	func testObserver() {
		let expectation = self.expectation(description: "observer")
		let observer = lightTarget.addObserver {
			expectation.fulfill()
		}
		lightTarget.setPower(true, duration: 0.0, completionHandler: nil)
		waitForExpectations(timeout: 3.0, handler: nil)
		lightTarget.removeObserver(observer)
	}
	
	func testSetPower() {
		let expectation = self.expectation(description: "setPower")
		let newPower = !lightTarget.power
		lightTarget.setPower(newPower, duration: 0.0, completionHandler: { (results, error) in
			DispatchQueue.main.async {
				XCTAssertNil(error, "expected error to be nil")
				XCTAssertEqual(newPower, self.lightTarget.power, "power is still new value after operation is completed")
				expectation.fulfill()
			}
		})
		XCTAssertEqual(newPower, lightTarget.power, "power is optimstically set to new value")
		waitForExpectations(timeout: 3.0, handler: nil)
	}
	
	func testSetBrightness() {
		let expectation = self.expectation(description: "setBrightness")
		let newBrightness = Double(arc4random_uniform(100)) / 100.0
		lightTarget.setBrightness(newBrightness, duration: 0.0) { (results, error) in
			DispatchQueue.main.async {
				XCTAssertNil(error, "expected error to be nil")
				XCTAssertEqual(newBrightness, self.lightTarget.brightness, "brightness is still new value after operation is completed")
				expectation.fulfill()
			}
		}
		XCTAssertEqual(newBrightness, lightTarget.brightness, "brightness is optimistically set to new value")
		waitForExpectations(timeout: 3.0, handler: nil)
	}
	
	func testSetColor() {
		let expectation = self.expectation(description: "setColor")
		let newColor = Color.color(Double(arc4random_uniform(360)), saturation: 0.5)
		lightTarget.setColor(newColor, duration: 0.0, completionHandler: { (results, error) in
			DispatchQueue.main.async {
				XCTAssertNil(error, "expected error to be nil")
				XCTAssertEqual(newColor.hue, self.lightTarget.color.hue, "hue is still new value after operation is completed")
				expectation.fulfill()
			}
		})
		XCTAssertEqual(newColor.hue, lightTarget.color.hue, "hue is optimsitically set to new value")
		waitForExpectations(timeout: 3.0, handler: nil)
	}
	
	func testRestoreState() {
		let client = ClientHelper.sharedClient
		if let scene = client.scenes.first {
			let expectation = self.expectation(description: "restoreState")
			
			let selector = LightTargetSelector(type: .SceneID, value: scene.uuid)
			let lightTarget = client.lightTargetWithSelector(selector)
			XCTAssertEqual(scene.name, lightTarget.label)
			lightTarget.restoreState(0.0) { (results, error) in
				XCTAssertNil(error, "expected error to be nil")
				expectation.fulfill()
			}
			
			waitForExpectations(timeout: 3.0, handler: nil)
		} else {
			print("Skipping \(#function): Authenticated account doesn't have any scenes")
		}
	}
	
	func testToGroupTargets() {
		let groups = lightTarget.toGroupTargets()
		XCTAssertGreaterThan(groups.count, 0, "expected at least one group")
		XCTAssertEqual(groups.first!.selector.type, LightTargetSelectorType.GroupID, "expected selector type to be GroupID")
	}
	
	func testToLocationTargets() {
		let locations = lightTarget.toLocationTargets()
		XCTAssertGreaterThan(locations.count, 0, "expected at least one location")
		XCTAssertEqual(locations.first!.selector.type, LightTargetSelectorType.LocationID, "expected selector type to be LocationID")
	}
	
	func testLightTargetTouchedAt() {
		XCTAssertEqualWithAccuracy(lightTarget.touchedAt.timeIntervalSinceNow, Date().timeIntervalSinceNow, accuracy: 10.0)
	}
}
