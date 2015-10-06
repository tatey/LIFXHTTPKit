//
//  Created by Tate Johnson on 6/10/2015.
//  Copyright © 2015 Tate Johnson. All rights reserved.
//

import Foundation

import XCTest
import LIFXHTTPKit

class SelectorTests: XCTestCase {
	func testNewSelectorWithRawSelectorHavingAll() {
		if let selector = LIFXHTTPKit.Selector(rawSelector: "all") {
			XCTAssertEqual(selector.type, Selector.Type.All)
			XCTAssertEqual(selector.value, "")
		} else {
			XCTFail("Expected selector to be constructed.")
		}
	}

	func testNewSelectorWithRawSelectorHavingIDAndValue() {
		if let selector = LIFXHTTPKit.Selector(rawSelector: "id:d3b2f2d97452") {
			XCTAssertEqual(selector.type, Selector.Type.ID)
			XCTAssertEqual(selector.value, "d3b2f2d97452")
		} else {
			XCTFail("Expected selector to be constructed.")
		}
	}

	func testNewSelectorWithRawSelectorHavingBadCombinations() {
		XCTAssertNil(LIFXHTTPKit.Selector(rawSelector: ""))
		XCTAssertNil(LIFXHTTPKit.Selector(rawSelector: "id:"))
		XCTAssertNil(LIFXHTTPKit.Selector(rawSelector: ":"))
	}
}
