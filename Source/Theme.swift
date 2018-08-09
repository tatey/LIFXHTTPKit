//
//  Theme.swift
//  LIFXHTTPKit
//
//  Created by Alexander Stonehouse on 9/8/18.
//  Copyright © 2018 Tate Johnson. All rights reserved.
//

import Foundation

public struct Theme: Equatable {
    public let uuid: String
    public let title: String
    public let imageUrl: String
    public let colors: [Color]
}
