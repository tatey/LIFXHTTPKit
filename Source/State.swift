//
//  Created by Tate Johnson on 6/10/2015.
//  Copyright © 2015 Tate Johnson. All rights reserved.
//

import Foundation

public struct State: Equatable {
	public let selector: LightTargetSelector
	public let brightness: Double?
	public let color: Color?
	public let power: Bool?
}

public func ==(lhs: State, rhs: State) -> Bool {
	return lhs.brightness == rhs.brightness &&
		lhs.color == rhs.color &&
		lhs.selector == rhs.selector
}
