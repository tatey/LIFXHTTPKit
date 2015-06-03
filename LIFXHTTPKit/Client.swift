//
//  Client.swift
//  LIFXHTTPKit
//
//  Created by Tate Johnson on 29/05/2015.
//  Copyright (c) 2015 Tate Johnson. All rights reserved.
//

import Foundation

public class Client {
	private let accessToken: String
	private var lights: [Light]
	private var observers: [LightTarget]

	public init(accessToken: String) {
		self.accessToken = accessToken
		lights = []
		observers = []
	}

	internal func addObserver(observer: LightTarget) {
		for other in observers {
			if other === observer {
				return
			}
		}
		observers.append(observer)
	}

	internal func removeObserver(observer: LightTarget) {
		for (index, other) in enumerate(observers) {
			if other === observer {
				observers.removeAtIndex(index)
				break
			}
		}
	}

	public func allLights() -> LightTarget {
		return LightTarget(client: self, filter: { (light: Light) -> Bool in return true })
	}

	public func allGroups() -> [LightTarget] {
		return []
	}

	public func allLocations() -> [LightTarget] {
		return []
	}
}

public struct Light: Equatable {
	public let id: String
	public let label: String
	public let power: Bool
	public let brightness: Float
}

public func ==(lhs: Light, rhs: Light) -> Bool {
	return lhs.id == rhs.id
}

public class LightTarget {
	public typealias Filter = (light: Light) -> Bool

	public var power: Bool
	public var brightness: Float

	private weak var client: Client?
	private let filter: Filter
	private var lights: [Light]

	init(client: Client, filter: Filter) {
		power = false
		brightness = 0.0
		self.client = client
		self.filter = filter
		lights = []

		client.addObserver(self)
	}

	deinit {
		client?.removeObserver(self)
	}

	internal func setLights(lights: [Light]) {
		self.lights = lights.filter(filter)
	}

	public func toLights() -> [Light] {
		return lights
	}
}
