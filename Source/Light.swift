//
//  Created by Tate Johnson on 13/06/2015.
//  Copyright (c) 2015 Tate Johnson. All rights reserved.
//

import Foundation

public struct Light: Equatable, Printable {
	public let id: String
	public let label: String
	public let power: Bool
	public let brightness: Double

	func lightWithPower(power: Bool) -> Light {
		return Light(id: id, label: label, power: power, brightness: brightness)
	}

	// MARK: Printable
	public var description: String {
		return "<Light id: \(id), label: \(label), power: \(power), brightness: \(brightness)>"
	}
}

public func ==(lhs: Light, rhs: Light) -> Bool {
	return lhs.id == rhs.id &&
		lhs.label == rhs.label &&
		lhs.power == rhs.power &&
		lhs.brightness == rhs.brightness
}
