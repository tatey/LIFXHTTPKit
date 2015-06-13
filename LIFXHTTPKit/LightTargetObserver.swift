//
//  Created by Tate Johnson on 13/06/2015.
//  Copyright (c) 2015 Tate Johnson. All rights reserved.
//

import Foundation

public class LightTargetObserver {
	public typealias StateDidUpdate = () -> Void

	internal let stateDidUpdate: StateDidUpdate

	init(closure: StateDidUpdate) {
		self.stateDidUpdate = closure
	}
}
