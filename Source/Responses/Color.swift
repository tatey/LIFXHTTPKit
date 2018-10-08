//
//  Created by Tate Johnson on 22/06/2015.
//  Copyright (c) 2015 Tate Johnson. All rights reserved.
//

import Foundation

public struct Color: Equatable, Codable, CustomStringConvertible {
	static let maxHue: Double = 360.0
	static let defaultKelvin: Int = 3500
	
	public let hue: Double
	public let saturation: Double
	public let kelvin: Int
	
	public init(hue: Double, saturation: Double, kelvin: Int) {
		self.hue = hue
		self.saturation = saturation
		self.kelvin = kelvin
	}
    
    public init?(query: String) {
        let components = query.split(separator: ":")
        if let first = components.first, first == "kelvin", components.count == 2, let kelvin = Int(components[1]) {
            self.hue = 0
            self.saturation = 0
            self.kelvin = kelvin
        } else if components.count == 3, let first = components.first, first == "hue" {
            let hueAndSaturation = components[1].split(separator: " ")
            if hueAndSaturation.count == 2, let first = hueAndSaturation.first, let hue = Double(first), hueAndSaturation[1] == "saturation", let last = components.last, let saturation = Double(last) {
                self.hue = hue
                self.saturation = saturation
                self.kelvin = Color.defaultKelvin
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
	
	public static func color(_ hue: Double, saturation: Double) -> Color {
		return Color(hue: hue, saturation: saturation, kelvin: Color.defaultKelvin)
	}
	
	public static func white(_ kelvin: Int) -> Color {
		return Color(hue: 0.0, saturation: 0.0, kelvin: kelvin)
	}
	
	public var isColor: Bool {
		return !isWhite
	}
	
	public var isWhite: Bool {
		return saturation == 0.0
	}
	
	public func toQueryStringValue() -> String {
		if isWhite {
			return "kelvin:\(kelvin)"
		} else {
			return "hue:\(hue) saturation:\(saturation)"
		}
	}
	
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
