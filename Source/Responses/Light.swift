//
//  Created by Tate Johnson on 13/06/2015.
//  Copyright (c) 2015 Tate Johnson. All rights reserved.
//

import Foundation

public struct Light: Decodable, Equatable, CustomStringConvertible {
	public let id: String
	public let power: Bool
	public let brightness: Double
	public let color: Color
    public let product: ProductInformation?
	public let label: String
	public let connected: Bool
	public let group: Group?
	public let location: Location?
	public let touchedAt = Date()
    
    @available(*, deprecated, message: "Use `product` instead.")
    public var productInfo: ProductInformation? {
        return product
    }
    
    init(id: String, power: Bool, brightness: Double, color: Color, product: ProductInformation?, label: String, connected: Bool, group: Group? = nil, location: Location? = nil) {
        self.id = id
        self.power = power
        self.brightness = brightness
        self.color = color
        self.product = product
        self.label = label
        self.connected = connected
        self.group = group
        self.location = location
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        let on = try container.decode(String.self, forKey: .power)
        power = on == "on"
        brightness = try container.decode(Double.self, forKey: .brightness)
        color = try container.decode(Color.self, forKey: .color)
        product = try container.decodeIfPresent(ProductInformation.self, forKey: .product)
        label = try container.decode(String.self, forKey: .label)
        connected = try container.decode(Bool.self, forKey: .connected)
        group = try container.decodeIfPresent(Group.self, forKey: .group)
        location = try container.decodeIfPresent(Location.self, forKey: .location)
    }
    
    private enum CodingKeys: String, CodingKey {
        case id
        case power
        case brightness
        case color
        case product
        case label
        case connected
        case group
        case location
    }
	
	public func toSelector() -> LightTargetSelector {
		return LightTargetSelector(type: .ID, value: id)
	}
	
	func lightWithProperties(_ power: Bool? = nil, brightness: Double? = nil, color: Color? = nil, productInformation: ProductInformation? = nil, connected: Bool? = nil) -> Light {
		return Light(id: id, power: power ?? self.power, brightness: brightness ?? self.brightness, color: color ?? self.color, product: productInformation ?? self.product, label: label, connected: connected ?? self.connected, group: group, location: location)
	}
	
	// MARK: Capabilities
	
	public var hasColor: Bool {
		return self.productInfo?.capabilities?.hasColor ?? false
	}
	
	public var hasIR: Bool {
		return self.productInfo?.capabilities?.hasIR ?? false
	}
	
	public var hasMultiZone: Bool {
		return self.productInfo?.capabilities?.hasMulitiZone ?? false
	}
	
	// MARK: Printable
	
	public var description: String {
		return "<Light id: \"\(id)\", label: \"\(label)\", power: \(power), brightness: \(brightness), color: \(color), connected: \(connected), group: \(String(describing: group)), location: \(String(describing: location)), touchedAt: \(String(describing: touchedAt))>"
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
