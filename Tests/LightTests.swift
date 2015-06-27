//
//  Created by Tate Johnson on 14/06/2015.
//  Copyright (c) 2015 Tate Johnson. All rights reserved.
//

import XCTest

class LightTests: XCTestCase {
	func testLightWithPowerReturnsNewInstance() {
		let light1 = Light(id: "d3b2f2d97452", power: false, brightness: 0.0, color: Color(hue: 0, saturation: 0, kelvin: 3500), label: "Left Lamp", connected: true)
		let light2 = light1.lightWithPower(true)
		XCTAssertNotEqual(light1, light2, "expected light1 not to equal light2")
		XCTAssertFalse(light1.power, "expected light1 to be powered off")
		XCTAssertTrue(light2.power, "expected light2 to be powered on")
	}
}
