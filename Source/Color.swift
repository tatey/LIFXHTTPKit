//
//  Created by Tate Johnson on 22/06/2015.
//  Copyright (c) 2015 Tate Johnson. All rights reserved.
//

import Foundation

public struct Color: Equatable, Printable {
	static let maxHue: Double = 360.0
	static let defaultKelvin: Int = 3500

	public let hue: Double
	public let saturation: Double
	public let kelvin: Int

	// MARK: Printable
	public var description: String {
		return "<Color hue: \(hue), saturation: \(saturation), kelvin: \(kelvin)>"
	}
}

public func ==(lhs: Color, rhs: Color) -> Bool {
	return lhs.hue == rhs.hue &&
		lhs.saturation == rhs.saturation &&
		lhs.kelvin == rhs.kelvin
}
