//
//  Created by Tate Johnson on 14/06/2015.
//  Copyright (c) 2015 Tate Johnson. All rights reserved.
//

import XCTest
@testable import LIFXHTTPKit

class LightTests: XCTestCase {
	func testLightWithPropertiesUsingPower() {
		let light1 = newLight()
		let light2 = light1.lightWithProperties(false)
		XCTAssertFalse(light2.power)
		XCTAssertNotEqual(light1, light2)
	}
	
	func testLightWithPropertiesUsingBrightness() {
		let light1 = newLight()
		let light2 = light1.lightWithProperties(brightness: 1.0)
		XCTAssertEqual(light2.brightness, 1.0)
		XCTAssertNotEqual(light1, light2)
	}
	
	func testLightWithPropertiesUsingColor() {
		let light1 = newLight()
		let light2 = light1.lightWithProperties(color: Color.white(5000))
		XCTAssertEqual(light2.color, Color.white(5000))
		XCTAssertNotEqual(light1, light2)
	}
	
	func testLightWithPropertiesUsingConnected() {
		let light1 = newLight()
		let light2 = light1.lightWithProperties(connected: false)
		XCTAssertFalse(light2.connected)
		XCTAssertNotEqual(light1, light2)
	}
	
	private func newLight() -> Light {
		return Light(id: "d3b2f2d97452", power: true, brightness: 0.5, color: Color.white(Color.defaultKelvin), productInfo: nil, label: "Lamp", connected: true, group: nil, location: nil, touchedAt: nil)
	}
}
