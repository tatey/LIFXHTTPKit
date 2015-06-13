//
//  Created by Tate Johnson on 13/06/2015.
//  Copyright (c) 2015 Tate Johnson. All rights reserved.
//

import Foundation

internal class ClientObserver {
	internal typealias LightsDidUpdate = (lights: [Light]) -> Void

	internal let lightsDidUpdate: LightsDidUpdate

	init(closure: LightsDidUpdate) {
		self.lightsDidUpdate = closure
	}
}
