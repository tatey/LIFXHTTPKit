//
//  Created by Tate Johnson on 13/06/2015.
//  Copyright (c) 2015 Tate Johnson. All rights reserved.
//

import Foundation

public struct Light: Equatable, CustomStringConvertible {
	public let id: String
	public let power: Bool
	public let brightness: Double
	public let color: Color
	public let label: String
	public let connected: Bool
	public let group: Group?
	public let location: Location?

	public func toSelector() -> LightTargetSelector {
		return LightTargetSelector(type: .ID, value: id)
	}

	func lightWithProperties(power: Bool? = nil, brightness: Double? = nil, color: Color? = nil, connected: Bool? = nil) -> Light {
		return Light(id: id, power: power ?? self.power, brightness: brightness ?? self.brightness, color: color ?? self.color, label: label, connected: connected ?? self.connected, group: group, location: location)
	}

	// MARK: Printable
	
	public var description: String {
		return "<Light id: \"\(id)\", label: \"\(label)\", power: \(power), brightness: \(brightness), color: \(color), connected: \(connected), group: \(group), location: \(location)>"
	}
}

public func ==(lhs: Light, rhs: Light) -> Bool {
	return lhs.id == rhs.id &&
		lhs.power == rhs.power &&
		lhs.brightness == rhs.brightness &&
		lhs.color == rhs.color &&
		lhs.label == rhs.label &&
		lhs.connected == rhs.connected &&
		lhs.group == rhs.group &&
		lhs.location == rhs.location
}
