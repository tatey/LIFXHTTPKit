//
//  Created by Tate Johnson on 6/10/2015.
//  Copyright © 2015 Tate Johnson. All rights reserved.
//

import Foundation

public struct Scene: Equatable {
	public let uuid: String
	public let name: String
	public let states: [State]
	
	public func toSelector() -> LightTargetSelector {
		return LightTargetSelector(type: .SceneID, value: uuid)
	}
}

public func ==(lhs: Scene, rhs: Scene) -> Bool {
	return lhs.uuid == rhs.uuid &&
		lhs.name == rhs.name &&
		lhs.states == rhs.states
}
