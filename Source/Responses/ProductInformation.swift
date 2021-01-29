//
//  ProductInformation.swift
//  LIFXHTTPKit
//
//  Created by LIFX Laptop on 5/4/17.

import Foundation

public struct ProductInformation: Codable {
	public let productName: String
	public let manufacturer: String
	public let capabilities: Capabilities?
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        productName = try container.decode(String.self, forKey: .productName)
        manufacturer = try container.decode(String.self, forKey: .manufacturer)
        capabilities = try container.decodeIfPresent(Capabilities.self, forKey: .capabilities)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(productName, forKey: .productName)
        try container.encode(manufacturer, forKey: .manufacturer)
        try container.encodeIfPresent(capabilities, forKey: .capabilities)
    }
	
	var description: String {
		return "Name: \(productName) - manufactured by \(manufacturer) Capabilities supported - \(String(describing: capabilities?.description))"
	}
    
    private enum CodingKeys: String, CodingKey {
        case productName = "name"
        case manufacturer = "company"
        case capabilities
    }
}

public struct Capabilities: Codable {
	public let hasColor: Bool
	public let hasIR: Bool
    public let hasHEV: Bool
	public let hasMulitiZone: Bool
    public let hasVariableColorTemp: Bool
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        hasColor = try container.decode(Bool.self, forKey: .hasColor)
        hasIR = try container.decode(Bool.self, forKey: .hasIR)
        hasHEV = try container.decode(Bool.self, forKey: .hasHEV)
        hasMulitiZone = try container.decode(Bool.self, forKey: .hasMultiZone)
        hasVariableColorTemp = try container.decode(Bool.self, forKey: .hasVariableColorTemp)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(hasColor, forKey: .hasColor)
        try container.encode(hasIR, forKey: .hasIR)
        try container.encode(hasHEV, forKey: .hasHEV)
        try container.encode(hasMulitiZone, forKey: .hasMultiZone)
        try container.encode(hasVariableColorTemp, forKey: .hasVariableColorTemp)
    }
	
	var description: String {
		return "Color - \(hasColor), Infra-red \(hasIR), Multiple zones - \(hasMulitiZone)"
	}
    
    private enum CodingKeys: String, CodingKey {
        case hasColor = "has_color"
        case hasIR = "has_ir"
        case hasHEV = "has_hev"
        case hasMultiZone = "has_multizone"
        case hasVariableColorTemp = "has_variable_color_temp"
    }
	
}
