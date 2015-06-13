//
//  Created by Tate Johnson on 29/05/2015.
//  Copyright (c) 2015 Tate Johnson. All rights reserved.
//

import XCTest
import LIFXHTTPKit

class LIFXHTTPKitTests: XCTestCase {
	func testClient() {
		let expectation = expectationWithDescription("")
		let client = Client(accessToken: "")
		client.discover()
		let lights = client.allLights()
		lights.addObserver {
			if lights.toLights().count > 0 {
				expectation.fulfill()
			}
		}
		waitForExpectationsWithTimeout(5.0, handler: nil)
	}
}
