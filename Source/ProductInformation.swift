//
//  ProductInformation.swift
//  LIFXHTTPKit
//
//  Created by LIFX Laptop on 5/4/17.
//  Copyright © 2017 Tate Johnson. All rights reserved.
//

import Foundation

public struct ProductInformation {
    public let productName: String?
    public let manufacturer: String?
    public let capabilities: Capabilities?
}

public struct Capabilities {
    public let hasColor: Bool?
    public let hasIR: Bool?
    public let hasMulitiZone: Bool?
}
