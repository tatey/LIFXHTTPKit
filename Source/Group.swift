//
//  Created by Tate Johnson on 15/07/2015.
//  Copyright (c) 2015 Tate Johnson. All rights reserved.
//

import Foundation

public struct Group: Equatable, CustomStringConvertible {
	public let id: String
	public let name: String
	
	public func toSelector() -> LightTargetSelector {
		return LightTargetSelector(type: .GroupID, value: id)
	}
	
	// MARK: Printable
	
	public var description: String {
		return "<Group id: \"\(id)\", label: \"\(name)\">"
	}
}

public func ==(lhs: Group, rhs: Group) -> Bool {
	return lhs.id == rhs.id && lhs.name == rhs.name
}
