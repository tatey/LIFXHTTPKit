//
//  Created by Tate Johnson on 29/05/2015.
//  Copyright (c) 2015 Tate Johnson. All rights reserved.
//

import XCTest
import LIFXHTTPKit

class ClientTests: XCTestCase {
	func testFetchWithCompletionHandlerGetsInvoked() {
		let expectation = expectationWithDescription("fetch")
		let client = Client(accessToken: "")
		client.fetch { (error) in
			XCTAssertNil(error, "expected error to be nil")
			expectation.fulfill()
		}
		waitForExpectationsWithTimeout(3.0, handler: nil)
	}

	func testAllLightsReturnsLightTargetConfiguredWithAllSelector() {
		let client = Client(accessToken: "")
		let lightTarget = client.allLightTarget()
		XCTAssertEqual(lightTarget.selector, Selector(type: .All), "expected selector to be `.All` type")
	}
}
