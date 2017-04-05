//
//  ProductInformation.swift
//  LIFXHTTPKit
//
//  Created by LIFX Laptop on 5/4/17.
//  Copyright © 2017 Tate Johnson. All rights reserved.
//

import Foundation

public struct ProductInformation {
    public let productName: String
    public let manufacturer: String
    public let capabilities: Capabilities?
    
    public init?(data: NSDictionary) {
        guard let name = data["name"] as? String, let company = data["company"] as? String, let productCapabilities = data["capabilities"] as? NSDictionary else {
            return nil
        }
        productName = name
        manufacturer = company
        capabilities = Capabilities(data: productCapabilities)
    }
    
    var description: String {
        return "Name: \(productName) - manufactured by \(manufacturer) Capabilities supported - \(String(describing: capabilities?.description))"
    }
}

public struct Capabilities {
    public let hasColor: Bool
    public let hasIR: Bool
    public let hasMulitiZone: Bool
    
    public init?(data: NSDictionary) {
        guard let hasColor = data["has_color"] as? Bool,
        let hasIR = data["has_ir"] as? Bool, let multiZone = data["has_multizone"] as? Bool else {
                return nil
        }
        
        self.hasColor = hasColor
        self.hasIR = hasIR
        self.hasMulitiZone = multiZone
    }
    
    var description: String {
        return "supports color - \(hasColor), supports Infra-red \(hasIR), multiple zones - \(hasMulitiZone)"
    }
    
}
