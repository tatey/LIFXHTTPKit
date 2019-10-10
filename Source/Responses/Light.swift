//
//  Created by Tate Johnson on 13/06/2015.
//  Copyright (c) 2015 Tate Johnson. All rights reserved.
//

import Foundation

public struct Light: Codable, Equatable, CustomStringConvertible {
    /// Toggle differs from a power state change because at the time the change is made the power state is indeterminate
    public enum MutableProperties: String, Equatable {
        case power, brightness, color, toggle
    }
    struct DirtyProperty: Equatable {
        let updatedAt: Date
        let property: MutableProperties
    }
    
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
    
    /// List of properties which have changes currently 'in-flight'. Any state requests made while the properties are 'in-flight' are inherently out of date.
    let inFlightProperties: [MutableProperties]
    /// Properties which have been updated, but haven't been reflected in a state request
    let dirtyProperties: [DirtyProperty]
    
    @available(*, deprecated, message: "Use `product` instead.")
    public var productInfo: ProductInformation? {
        return product
    }
    
    init(id: String, power: Bool, brightness: Double, color: Color, product: ProductInformation?, label: String, connected: Bool, group: Group? = nil, location: Location? = nil, inFlightProperties: [MutableProperties], dirtyProperties: [DirtyProperty]) {
        self.id = id
        self.power = power
        self.brightness = brightness
        self.color = color
        self.product = product
        self.label = label
        self.connected = connected
        self.group = group
        self.location = location
        self.inFlightProperties = inFlightProperties
        self.dirtyProperties = dirtyProperties
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
        dirtyProperties = []
        inFlightProperties = []
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        let powerString = power ? "on" : "off"
        try container.encode(powerString, forKey: .power)
        try container.encode(brightness, forKey: .brightness)
        try container.encode(color, forKey: .color)
        try container.encodeIfPresent(product, forKey: .product)
        try container.encode(label, forKey: .label)
        try container.encode(connected, forKey: .connected)
        try container.encode(group, forKey: .group)
        try container.encode(location, forKey: .location)
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
    
    public var isDirty: Bool {
        return dirtyProperties.count > 0 || inFlightProperties.count > 0
    }
	
	public func toSelector() -> LightTargetSelector {
		return LightTargetSelector(type: .ID, value: id)
	}
	
    func lightWithProperties(_ power: Bool? = nil, brightness: Double? = nil, color: Color? = nil, productInformation: ProductInformation? = nil, connected: Bool? = nil, inFlightProperties: [MutableProperties]? = nil, dirtyProperties: [DirtyProperty]? = nil) -> Light {
        return Light(id: id, power: power ?? self.power, brightness: brightness ?? self.brightness, color: color ?? self.color, product: productInformation ?? self.product, label: label, connected: connected ?? self.connected, group: group, location: location, inFlightProperties: inFlightProperties ?? self.inFlightProperties, dirtyProperties: dirtyProperties ?? self.dirtyProperties)
	}
    
    /// Creates an updated Light with the given updated state (presumably from the cloud). The requested timestamp is used to determine whether state changes are still
    /// dirty. If the request was made before state changes were completed then those properties will remain unchanged (pending a subsequent state update).
    ///
    /// - Parameters:
    ///   - updatedLight: Light with updated state from the cloud
    ///   - requestedAt: Timestamp when the request was started
    /// - Returns: Updated Light including new state and any dirty properties
    func light(withUpdatedLight updatedLight: Light, requestedAt: Date) -> Light {
        var mutLight = updatedLight
        let stillDirtyProperties: [DirtyProperty] = dirtyProperties.compactMap {
            // Make sure the state info was requested after the dirty property was no longer in-flight
            if requestedAt.timeIntervalSince($0.updatedAt) > 0 {
                return nil
            }
            return $0
        }
        var dirtyProps: [MutableProperties] = stillDirtyProperties.map { $0.property }
        
        inFlightProperties.forEach { inFlight in
            if !dirtyProps.contains(inFlight) {
                dirtyProps.append(inFlight)
            }
        }
        dirtyProps.forEach { dirtyProp in
            switch dirtyProp {
            case .brightness:
                mutLight = mutLight.lightWithProperties(brightness: brightness)
            case .color:
                mutLight = mutLight.lightWithProperties(color: color)
            case .power:
                mutLight = mutLight.lightWithProperties(power)
            case .toggle:
                // Toggle is in flight, so flip whatever the state from the cloud was
                mutLight = mutLight.lightWithProperties(!mutLight.power)
            }
        }
        return mutLight.lightWithProperties(inFlightProperties: inFlightProperties, dirtyProperties: stillDirtyProperties)
    }
	
	// MARK: Capabilities
	
	public var hasColor: Bool {
		return self.product?.capabilities?.hasColor ?? false
	}
	
	public var hasIR: Bool {
		return self.product?.capabilities?.hasIR ?? false
	}
	
	public var hasMultiZone: Bool {
		return self.product?.capabilities?.hasMulitiZone ?? false
	}
    
    public var hasVariableColorTemp: Bool {
        return self.product?.capabilities?.hasVariableColorTemp ?? false
    }
	
	// MARK: Printable
	
	public var description: String {
		return "<Light id: \"\(id)\", label: \"\(label)\", power: \(power), brightness: \(brightness), color: \(color), connected: \(connected), group: \(String(describing: group)), location: \(String(describing: location)), touchedAt: \(String(describing: touchedAt))>"
	}
}

public func == (lhs: Light, rhs: Light) -> Bool {
	return lhs.id == rhs.id &&
		lhs.power == rhs.power &&
		lhs.brightness == rhs.brightness &&
		lhs.color == rhs.color &&
		lhs.label == rhs.label &&
		lhs.connected == rhs.connected &&
		lhs.group == rhs.group &&
		lhs.location == rhs.location &&
        lhs.inFlightProperties == rhs.inFlightProperties &&
        lhs.dirtyProperties == rhs.dirtyProperties
}
