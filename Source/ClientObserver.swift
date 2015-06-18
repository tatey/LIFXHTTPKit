//
//  Created by Tate Johnson on 13/06/2015.
//  Copyright (c) 2015 Tate Johnson. All rights reserved.
//

import Foundation

class ClientObserver {
	typealias LightsDidUpdate = (lights: [Light]) -> Void

	let lightsDidUpdateHandler: LightsDidUpdate

	init(lightsDidUpdateHandler: LightsDidUpdate) {
		self.lightsDidUpdateHandler = lightsDidUpdateHandler
	}
}
