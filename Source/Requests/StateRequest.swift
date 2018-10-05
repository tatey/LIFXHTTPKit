//
//  StateRequest.swift
//  LIFXHTTPKit-iOS
//
//  Created by Megan Efron on 3/10/18.
//

import Foundation

struct StateRequest: Encodable {
    let power: Bool?
    let color: String?
    let brightness: Double?
    let duration: Float
}
