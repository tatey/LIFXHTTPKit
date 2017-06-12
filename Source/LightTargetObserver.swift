//
//  Created by Tate Johnson on 13/06/2015.
//  Copyright (c) 2015 Tate Johnson. All rights reserved.
//

import Foundation

public class LightTargetObserver {
	public typealias StateDidUpdate = () -> Void
	
	let stateDidUpdateHandler: StateDidUpdate
	
	init(stateDidUpdateHandler: @escaping StateDidUpdate) {
		self.stateDidUpdateHandler = stateDidUpdateHandler
	}
}
