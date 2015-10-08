//
//  Created by Tate Johnson on 8/10/2015.
//  Copyright © 2015 Tate Johnson. All rights reserved.
//

import Foundation

public enum LightTargetSelectorType: String {
	case All        = "all"
	case ID         = "id"
	case GroupID    = "group_id"
	case LocationID = "location_id"
	case SceneID    = "scene_id"
	case Label      = "label"
}

public struct LightTargetSelector: Equatable, CustomStringConvertible {
	public let type: LightTargetSelectorType
	public let value: String

	public init(type: LightTargetSelectorType, value: String = "") {
		self.type = type
		self.value = value

		if (type == .Label) {
			print("Constructing selectors with `.Label` type is deprecated and will be removed in a future version.")
		}
	}

	public init?(rawSelector: String) {
		let components = rawSelector.componentsSeparatedByString(":")
		if let type = LightTargetSelectorType(rawValue: components.first ?? "") {
			if type == .All {
				self.type = type
				value = ""
			} else if let value = components.last where value.characters.count > 0 {
				self.type = type
				self.value = value
			} else {
				return nil
			}
		} else {
			return nil
		}
	}

	func toQueryStringValue() -> String {
		if type == .All {
			return type.rawValue
		} else {
			return "\(type.rawValue):\(value)"
		}
	}

	// MARK: Printable

	public var description: String {
		return "<Selector type: \"\(type)\", value: \"\(value)\">"
	}
}

public func ==(lhs: LightTargetSelector, rhs: LightTargetSelector) -> Bool {
	if lhs.type == .All {
		return lhs.type == rhs.type
	} else {
		return lhs.type == rhs.type && lhs.value == rhs.value
	}
}
