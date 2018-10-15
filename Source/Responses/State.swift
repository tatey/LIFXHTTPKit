//
//  Created by Tate Johnson on 6/10/2015.
//  Copyright © 2015 Tate Johnson. All rights reserved.
//

import Foundation

public struct State: Codable, Equatable {
	public let selector: LightTargetSelector
	public let brightness: Double?
	public let color: Color?
	public let power: Bool?
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let selectorValue = try container.decode(String.self, forKey: .selector)
        guard let selector = LightTargetSelector(stringValue: selectorValue) else {
            throw Errors.invalidSelector
        }
        self.selector = selector
        
        let on = try container.decode(String.self, forKey: .power)
        power = on == "on"
        brightness = try container.decode(Double.self, forKey: .brightness)
        color = try container.decode(Color.self, forKey: .color)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(selector.toQueryStringValue(), forKey: .selector)
        let powerString = (power ?? false) ? "on" : "off"
        try container.encode(powerString, forKey: .power)
        try container.encode(brightness, forKey: .brightness)
        try container.encode(color, forKey: .color)
    }
    
    private enum CodingKeys: String, CodingKey {
        case selector
        case brightness
        case color
        case power
    }
    
    enum Errors: Error {
        case invalidSelector
    }
}

public func ==(lhs: State, rhs: State) -> Bool {
	return lhs.brightness == rhs.brightness &&
		lhs.color == rhs.color &&
		lhs.selector == rhs.selector
}
