//
//  Created by Tate Johnson on 29/05/2015.
//  Copyright (c) 2015 Tate Johnson. All rights reserved.
//

import XCTest
import LIFXHTTPKit

class ClientTests: XCTestCase {
	func testAllLightsReturnsLightTargetConfiguredWithAllSelector() {
		let client = Client(accessToken: "")
		let lightTarget = client.allLightTarget()
		XCTAssertEqual(lightTarget.selector, LightTargetSelector(type: .All), "Expected selector to be `.All` type")
	}
	
	func testFetchWithInvalidAccessTokenSetsErrors() {
		let expectation = self.expectation(description: "fetch")
		
		let client = Client(accessToken: "")
		client.fetch { (errors) in
			XCTAssertGreaterThan(errors.count, 0)
			expectation.fulfill()
		}
		
		waitForExpectations(timeout: 3.0, handler: nil)
	}
}
