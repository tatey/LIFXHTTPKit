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
		XCTAssertEqual(lightTarget.selector, LightTargetSelector(type: .All), "expected selector to be `.All` type")
	}
}
