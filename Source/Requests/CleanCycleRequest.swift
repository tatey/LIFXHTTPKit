//
//  CleanCycleRequest.swift
//  Pods
//
//  Created by Jason Chan on 4/1/21.
//

import Foundation

struct CleanCycleRequest: Encodable {

    private let stop: Bool?
    private let duration: Float?

    init(isActive: Bool, duration: Float?) {
        self.stop = isActive ? nil : true
        self.duration = duration
    }
}
