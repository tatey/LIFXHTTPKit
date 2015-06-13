//
//  Created by Tate Johnson on 13/06/2015.
//  Copyright (c) 2015 Tate Johnson. All rights reserved.
//

import Foundation

public class LightTarget {
	internal typealias Filter = (light: Light) -> Bool

	public var power: Bool
	public var brightness: Float

	public let selector: String
	private let filter: Filter

	private var lights: [Light]
	private var observers: [LightTargetObserver]

	private unowned let client: Client
	private var clientObserver: ClientObserver!

	init(client: Client, selector: String, filter: Filter) {
		power = false
		brightness = 0.0

		self.selector = selector
		self.filter = filter

		lights = []
		observers = []

		self.client = client
		clientObserver = client.addObserver { [unowned self] (lights) in
			self.setLightsByApplyingFilter(lights)
		}
	}

	deinit {
		client.removeObserver(clientObserver)
	}

	public func addObserver(stateDidUpdateHandler: LightTargetObserver.StateDidUpdate) -> LightTargetObserver {
		let observer = LightTargetObserver(stateDidUpdateHandler: stateDidUpdateHandler)
		observers.append(observer)
		return observer
	}

	public func removeObserver(observer: LightTargetObserver) {
		for (index, other) in enumerate(observers) {
			if other === observer {
				observers.removeAtIndex(index)
			}
		}
	}

	public func removeAllObservers() {
		observers = []
	}

	public func toLights() -> [Light] {
		return lights
	}

	public func setOn(on: Bool, duration: Float = 1.0) {
		setOn(on, duration: duration, completionHandler: nil)
	}

	public func setOn(on: Bool, duration: Float = 1.0, completionHandler: ((results: [Result], error: NSError?) -> Void)?) {
		client.session.setLightsPower(selector, on: on, duration: duration) { (request, response, results, error) in
			completionHandler?(results: results, error: error)
		}
	}

	private func setLightsByApplyingFilter(lights: [Light]) {
		let oldLights = self.lights
		let newLights = lights.filter(filter)
		if oldLights != newLights {
			self.lights = newLights
			for observer in observers {
				observer.stateDidUpdateHandler()
			}
		}
	}
}
