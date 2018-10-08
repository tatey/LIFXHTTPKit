//
//  StateRequest.swift
//  LIFXHTTPKit-iOS
//
//  Created by Megan Efron on 3/10/18.
//

import Foundation

struct StateRequest: Encodable {
    enum Power: String, Encodable {
        case on, off
    }
    let power: Power?
    let color: String?
    let brightness: Double?
    let duration: Float
}

extension Bool {
    var asPower: StateRequest.Power {
        return self ? .on : .off
    }
}
