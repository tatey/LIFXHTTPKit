//
//  ProductInformation.swift
//  LIFXHTTPKit
//
//  Created by LIFX Laptop on 5/4/17.

import Foundation

public struct ProductInformation: Decodable {
	public let productName: String
	public let manufacturer: String
	public let capabilities: Capabilities?
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        productName = try container.decode(String.self, forKey: .productName)
        manufacturer = try container.decode(String.self, forKey: .manufacturer)
        capabilities = try container.decodeIfPresent(Capabilities.self, forKey: .capabilities)
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

public struct Capabilities: Decodable {
	public let hasColor: Bool
	public let hasIR: Bool
	public let hasMulitiZone: Bool
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        hasColor = try container.decode(Bool.self, forKey: .hasColor)
        hasIR = try container.decode(Bool.self, forKey: .hasIR)
        hasMulitiZone = try container.decode(Bool.self, forKey: .hasMultiZone)
    }
	
	var description: String {
		return "Color - \(hasColor), Infra-red \(hasIR), Multiple zones - \(hasMulitiZone)"
	}
    
    private enum CodingKeys: String, CodingKey {
        case hasColor = "has_color"
        case hasIR = "has_ir"
        case hasMultiZone = "has_multizone"
    }
	
}
