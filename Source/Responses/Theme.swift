//
//  Theme.swift
//  LIFXHTTPKit
//
//  Created by Alexander Stonehouse on 9/8/18.
//  Copyright © 2018 Tate Johnson. All rights reserved.
//

import Foundation

public struct Theme: Equatable, Codable {
    public let uuid: String
    public let title: String
    public let invocation: String?
    public let analytics: String
    public let image_url: String
    public let order: Int
    public let colors: [Color]
}

public func == (lhs: Theme, rhs: Theme) -> Bool {
    return lhs.uuid == rhs.uuid
}
