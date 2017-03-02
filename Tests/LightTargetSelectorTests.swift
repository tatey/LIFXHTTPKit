//
//  Created by Tate Johnson on 6/10/2015.
//  Copyright © 2015 Tate Johnson. All rights reserved.
//

import Foundation

import XCTest
import LIFXHTTPKit

class LightTargetSelectorTests: XCTestCase {
	func testNewSelectorWithRawSelectorHavingAll() {
		if let selector = LightTargetSelector(stringValue: "all") {
			XCTAssertEqual(selector.type, LightTargetSelectorType.All)
			XCTAssertEqual(selector.value, "")
		} else {
			XCTFail("Expected selector to be constructed.")
		}
	}
	
	func testNewSelectorWithRawSelectorHavingIDAndValue() {
		if let selector = LightTargetSelector(stringValue: "id:d3b2f2d97452") {
			XCTAssertEqual(selector.type, LightTargetSelectorType.ID)
			XCTAssertEqual(selector.value, "d3b2f2d97452")
		} else {
			XCTFail("Expected selector to be constructed.")
		}
	}
	
	func testNewSelectorWithRawSelectorHavingBadCombinations() {
		XCTAssertNil(LightTargetSelector(stringValue: ""))
		XCTAssertNil(LightTargetSelector(stringValue: "id:"))
		XCTAssertNil(LightTargetSelector(stringValue: ":"))
	}
	
	func testStringValue() {
		let selector1 = LightTargetSelector(type: .ID, value: "d3b2f2d97452")
		XCTAssertEqual(selector1.stringValue, "id:d3b2f2d97452")
		
		let selector2 = LightTargetSelector(type: .All)
		XCTAssertEqual(selector2.stringValue, "all")
	}
}
