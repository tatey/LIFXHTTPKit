//
//  Created by Tate Johnson on 13/06/2015.
//  Copyright (c) 2015 Tate Johnson. All rights reserved.
//

import Foundation

public class LightTarget {
	public private(set) var power: Bool
	public private(set) var brightness: Double
	public private(set) var label: String
	public private(set) var connected: Bool
	public private(set) var count: Int

	public let selector: Selector

	private var lights: [Light]
	private var observers: [LightTargetObserver]

	private unowned let client: Client
	private var clientObserver: ClientObserver!

	init(client: Client, selector: Selector) {
		power = false
		brightness = 0.0
		label = ""
		count = 0
		connected = false

		self.selector = selector

		lights = []
		observers = []

		self.client = client
		clientObserver = client.addObserver { [unowned self] (lights) in
			self.setLightsByApplyingFilterWithLights(lights)
		}

		setLightsByApplyingFilterWithLights(client.getLights())
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

	public func toLightTargets() -> [LightTarget] {
		return lights.map { (light) in return self.client.lightTargetWithSelector(Selector(type: .ID, value: light.id)) }
	}

	public func toGroupLightTargets() -> [LightTarget] {
		return []
	}

	public func toLocationLightTargets() -> [LightTarget] {
		return []
	}

	public func toLights() -> [Light] {
		return lights
	}

	public func setPower(power: Bool, duration: Float = 0.5, completionHandler: ((results: [Result], error: NSError?) -> Void)? = nil) {
		let newPower = power
		let oldPower = self.power
		client.setLightsByReplacingWithLights(self.lights.map { (light) in return light.lightWithPower(newPower) })
		client.session.setLightsPower(selector.toString(), power: newPower, duration: duration) { [unowned self] (request, response, results, error) in
			var newLights = self.lights(self.lights, byDeterminingConnectivityWithResults: results)
			if error != nil {
				newLights = newLights.map { (light) in return light.lightWithPower(oldPower) }
			}
			self.client.setLightsByReplacingWithLights(newLights)
			completionHandler?(results: results, error: error)
		}
	}

	private func setLightsByApplyingFilterWithLights(lights: [Light]) {
		self.lights = lights.filter(self.selector.toFilter())
		dirtyCheck()
	}

	private func lights(lights: [Light], byDeterminingConnectivityWithResults results: [Result]) -> [Light] {
		return lights.map { (light) in
			for result in results {
				if result.id == light.id {
					switch result.status {
					case .OK:
						return light.lightWithConnected(true)
					case .TimedOut, .Offline:
						return light.lightWithConnected(false)
					}
				}
			}
			return light
		}
	}

	private func dirtyCheck() {
		var dirty = false

		let newPower = derivePower()
		if power != newPower {
			power = newPower
			dirty = true
		}

		let newBrightness = deriveBrightness()
		if brightness != newBrightness {
			brightness = newBrightness
			dirty = true
		}

		let newLabel = deriveLabel()
		if label != newLabel {
			label = newLabel
			dirty = true
		}

		let newConnected = deriveConnected()
		if connected != newConnected {
			connected = newConnected
			dirty = true
		}

		let newCount = deriveCount()
		if count != newCount {
			count = newCount
			dirty = true
		}

		if dirty {
			notifyObservers()
		}
	}

	private func derivePower() -> Bool {
		for light in lights {
			if light.power {
				return true
			}
		}
		return false
	}

	private func deriveBrightness() -> Double {
		let count = deriveCount()
		if count > 0 {
			return lights.reduce(0.0) { (sum, light) in return light.brightness + sum } / Double(count)
		} else {
			return 0.0
		}
	}

	private func deriveLabel() -> String {
		switch selector.type {
		case .All:
			return "All"
		case .ID, .Label:
			return lights.first?.label ?? ""
		}
	}

	private func deriveConnected() -> Bool {
		for light in lights {
			if light.connected {
				return true
			}
		}
		return false
	}

	private func deriveCount() -> Int {
		return lights.count
	}

	private func notifyObservers() {
		for observer in observers {
			observer.stateDidUpdateHandler()
		}
	}
}
