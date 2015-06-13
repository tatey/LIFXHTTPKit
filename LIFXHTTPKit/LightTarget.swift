//
//  Created by Tate Johnson on 13/06/2015.
//  Copyright (c) 2015 Tate Johnson. All rights reserved.
//

import Foundation

public class LightTarget {
	public typealias Filter = (light: Light) -> Bool

	public var power: Bool
	public var brightness: Float

	private let filter: Filter
	private var lights: [Light]
	private var observers: [LightTargetObserver]

	private unowned let client: Client
	private var clientObserver: ClientObserver!

	init(client: Client, filter: Filter) {
		power = false
		brightness = 0.0

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
