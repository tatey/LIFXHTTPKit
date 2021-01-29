//
//  Created by Tate Johnson on 13/06/2015.
//  Copyright (c) 2015 Tate Johnson. All rights reserved.
//

import Foundation

typealias LightTargetFilter = (_ light: Light) -> Bool

public class LightTarget {
	public static let defaultDuration: Float = 0.5
	
	public private(set) var power: Bool
	public private(set) var brightness: Double
	public private(set) var color: Color
	public private(set) var label: String
	public private(set) var connected: Bool
	public private(set) var count: Int
	public private(set) var touchedAt: Date
	
	public let selector: LightTargetSelector
	public private(set) var lights: [Light]
	private let filter: LightTargetFilter
	private var observers: [LightTargetObserver]
	
	private let client: Client
	private var clientObserver: ClientObserver!
	
	init(client: Client, selector: LightTargetSelector, filter: @escaping LightTargetFilter) {
		power = false
		brightness = 0.0
		color = Color(hue: 0, saturation: 0, kelvin: Color.defaultKelvin)
		label = ""
		connected = false
		count = 0
		touchedAt = Date(timeIntervalSince1970: 0.0)
		
		self.selector = selector
		self.filter = filter
		lights = []
		observers = []
		
		self.client = client
		clientObserver = client.addObserver { [unowned self] (lights) in
			self.updateLights(lights)
		}
		
		updateLights(client.lights)
	}
	
	deinit {
		client.removeObserver(observer: clientObserver)
	}
	
	// MARK: Observers
	
	public func addObserver(_ stateDidUpdateHandler: @escaping LightTargetObserver.StateDidUpdate) -> LightTargetObserver {
		let observer = LightTargetObserver(stateDidUpdateHandler: stateDidUpdateHandler)
		observers.append(observer)
		return observer
	}
	
	public func removeObserver(_ observer: LightTargetObserver) {
		for (index, other) in observers.enumerated() {
			if other === observer {
				observers.remove(at: index)
			}
		}
	}
	
	public func removeAllObservers() {
		observers = []
	}
	
	private func notifyObservers() {
		for observer in observers {
			observer.stateDidUpdateHandler()
		}
	}
	
	// MARK: Slicing

    public func toLightTargets(filter: ((Light) -> Bool) = { _ in true }) -> [LightTarget] {
        lights
            .filter(filter)
            .map { light in
                 self.client.lightTargetWithSelector(LightTargetSelector(type: .ID, value: light.id))
            }
    }

    public func toGroupTargets(filter: ((Light) -> Bool) = { _ in true }) -> [LightTarget] {
        lights
            .filter(filter)
            .reduce([]) { (groups, light) -> [Group] in
                if let group = light.group, !groups.contains(group) {
                    return groups + [group]
                } else {
                    return groups
                }
            }
            .map { (group) in
                return self.client.lightTargetWithSelector(group.toSelector())
            }
    }

    public func toLocationTargets(filter: ((Light) -> Bool) = { _ in true }) -> [LightTarget] {
        lights
            .filter(filter)
            .reduce([]) { (locations, light) -> [Location] in
                if let location = light.location, !locations.contains(location) {
                    return locations + [location]
                } else {
                    return locations
                }
            }
            .map { (location) in
                return self.client.lightTargetWithSelector(location.toSelector())
            }
    }
	
	// MARK: Lighting Operations
    
    public func fetch() {
        client.fetchLight(selector)
    }
	
	public func setPower(_ power: Bool, duration: Float = LightTarget.defaultDuration, completionHandler: ((_ results: [Result], _ error: Error?) -> Void)? = nil) {
		let oldPower = self.power
        client.updateLights(lights.map({ $0.lightWithProperties(power, inFlightProperties: [.power]) }))
		client.session.setLightsState(selector.toQueryStringValue(), power: power, duration: duration) { [weak self] (request, response, results, error) in
			if let strongSelf = self {
				var newLights = strongSelf.lightsByDeterminingConnectivityWithResults(strongSelf.lights, results: results, removingInFlightProperties: [.power])
				if error != nil {
					newLights = newLights.map({ $0.lightWithProperties(oldPower) })
				}
				strongSelf.client.updateLights(newLights)
			}
			completionHandler?(results, error)
		}
	}
    
    public func togglePower(_ duration: Float = LightTarget.defaultDuration, completionHandler: ((_ results: [Result], _ error: Error?) -> Void)? = nil) {
        client.updateLights(lights.map({ $0.lightWithProperties(!power, inFlightProperties: [.toggle]) }))
        client.session.togglePower(selector.toQueryStringValue(), duration: duration) { [weak self] (request, response, results, error) in
            guard let `self` = self else {
                completionHandler?(results, error)
                return
            }
            let newLights: [Light] = self
                .lightsByDeterminingConnectivityWithResults(self.lights, results: results, removingInFlightProperties: [.toggle])
                .map { light in
                    guard let result = results.first(where: { $0.id == light.id }), let power = result.power else {
                        return light
                    }
                    return light.lightWithProperties(power == .on)
                }

            self.client.updateLights(newLights)
            completionHandler?(results, error)
        }
    }
	
	public func setBrightness(_ brightness: Double, duration: Float = LightTarget.defaultDuration, completionHandler: ((_ results: [Result], _ error: Error?) -> Void)? = nil) {
		let oldBrightness = self.brightness
        client.updateLights(lights.map({ $0.lightWithProperties(brightness: brightness, inFlightProperties: [.brightness]) }))
		client.session.setLightsState(selector.toQueryStringValue(), brightness: brightness, duration: duration) { [weak self] (request, response, results, error) in
			if let strongSelf = self {
				var newLights = strongSelf.lightsByDeterminingConnectivityWithResults(strongSelf.lights, results: results, removingInFlightProperties: [.brightness])
				if error != nil {
					newLights = newLights.map({ $0.lightWithProperties(brightness: oldBrightness) })
				}
				strongSelf.client.updateLights(newLights)
			}
			completionHandler?(results, error)
		}
	}
	
	public func setColor(_ color: Color, duration: Float = LightTarget.defaultDuration, completionHandler: ((_ results: [Result], _ error: Error?) -> Void)? = nil) {
		let oldColor = self.color
        client.updateLights(lights.map({ $0.lightWithProperties(color: color, inFlightProperties: [.color]) }))
		client.session.setLightsState(selector.toQueryStringValue(), color: color.toQueryStringValue(), duration: duration) { [weak self] (request, response, results, error) in
			if let strongSelf = self {
				var newLights = strongSelf.lightsByDeterminingConnectivityWithResults(strongSelf.lights, results: results, removingInFlightProperties: [.color])
				if error != nil {
					newLights = newLights.map({ $0.lightWithProperties(color: oldColor) })
				}
				strongSelf.client.updateLights(newLights)
			}
			completionHandler?(results, error)
		}
	}
    
    public func applyTheme(_ theme: Theme, duration: Float = LightTarget.defaultDuration, completionHandler: ((_ results: [Result], _ error: Error?) -> Void)? = nil) {
        client.session.applyTheme(selector.toQueryStringValue(), theme: theme.title, duration: duration) { (request, response, results, error) in
            completionHandler?(results, error)
        }
    }
	
	public func setColor(_ color: Color, brightness: Double, power: Bool? = nil, duration: Float = LightTarget.defaultDuration, completionHandler: ((_ results: [Result], _ error: Error?) -> Void)? = nil) {
		print("`setColor:brightness:power:duration:completionHandler: is deprecated and will be removed in a future version. Use `setState:brightness:power:duration:completionHandler:` instead.")
		return setState(color, brightness: brightness, power: power, duration: duration, completionHandler: completionHandler)
	}
	
	public func setState(_ color: Color? = nil, brightness: Double? = nil, power: Bool? = nil, duration: Float = LightTarget.defaultDuration, completionHandler: ((_ results: [Result], _ error: Error?) -> Void)? = nil) {
		let oldBrightness = self.brightness
		let oldColor = self.color
		let oldPower = self.power
        client.updateLights(lights.map({ $0.lightWithProperties(power, brightness: brightness, color: color, inFlightProperties: [.color, .power, .brightness]) }))
		client.session.setLightsState(selector.toQueryStringValue(), power: power, color: color?.toQueryStringValue(), brightness: brightness, duration: duration) { [weak self] (request, response, results, error) in
			if let strongSelf = self {
				var newLights = strongSelf.lightsByDeterminingConnectivityWithResults(strongSelf.lights, results: results, removingInFlightProperties: [.color, .power, .brightness])
				if error != nil {
					newLights = newLights.map({ $0.lightWithProperties(oldPower, brightness: oldBrightness, color: oldColor) })
				}
				strongSelf.client.updateLights(newLights)
			}
			completionHandler?(results, error)
		}
	}
	
	public func restoreState(_ duration: Float = LightTarget.defaultDuration, completionHandler: ((_ results: [Result], _ error: Error?) -> Void)? = nil) {
		if selector.type != .SceneID {
			let error = HTTPKitError(code: .unacceptableSelector, message: "Unsupported Selector. Only `.SceneID` is supported.")
			completionHandler?([], error)
			return
		}
		
		let states: [State]
		if let index = client.scenes.firstIndex(where: { $0.toSelector() == selector }) {
			states = client.scenes[index].states
		} else {
			states = []
		}
		let oldLights = lights
		let newLights = oldLights.map { (light) -> Light in
			if let index = states.firstIndex(where: { $0.selector == light.toSelector() }) {
				let state = states[index]
				let brightness = state.brightness ?? light.brightness
				let color = state.color ?? light.color
				let power = state.power ?? light.power
                return light.lightWithProperties(power, brightness: brightness, color: color, inFlightProperties: [.color, .power, .brightness])
			} else {
				return light
			}
		}
		
		client.updateLights(newLights)
		client.session.setScenesActivate(selector.toQueryStringValue()) { [weak self] (request, response, results, error) in
			if let strongSelf = self {
				var newLights = strongSelf.lightsByDeterminingConnectivityWithResults(strongSelf.lights, results: results, removingInFlightProperties: [.color, .power, .brightness])
				if error != nil {
					newLights = newLights.map { (newLight) -> Light in
						if let index = oldLights.firstIndex(where: { $0.id == newLight.id }) {
							let oldLight = oldLights[index]
							return oldLight.lightWithProperties(connected: newLight.connected)
						} else {
							return newLight
						}
					}
				}
				strongSelf.client.updateLights(newLights)
			}
			completionHandler?(results, error)
		}
	}
	
	// MARK: Helpers
	
	private func updateLights(_ lights: [Light]) {
		self.lights = lights.filter(filter)
		dirtyCheck()
	}
	
    private func lightsByDeterminingConnectivityWithResults(_ lights: [Light], results: [Result], removingInFlightProperties toRemove: [Light.MutableProperties]) -> [Light] {
        let timestamp = Date()
		return lights.map { (light) in
            let newInFlightProperties = light.inFlightProperties.filter { !toRemove.contains($0) }
            var dirtyProperties = light.dirtyProperties
            toRemove.forEach { notInFlight in
                if !dirtyProperties.contains(where: { $0.property == notInFlight }) {
                    dirtyProperties.append(Light.DirtyProperty(updatedAt: timestamp, property: notInFlight))
                }
            }
			for result in results {
				if result.id == light.id {
					switch result.status {
					case .OK, .Async:
                        return light.lightWithProperties(connected: true, inFlightProperties: newInFlightProperties, dirtyProperties: dirtyProperties)
					case .TimedOut, .Offline:
                        // If failed, use new inFlight which removes the inFlight properties and use old dirtyProperties so that that property is not considered dirty
                        return light.lightWithProperties(connected: false, inFlightProperties: newInFlightProperties, dirtyProperties: light.dirtyProperties)
					}
				}
			}
			return light
		}
	}
	
	// MARK: Dirty Checking
	
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
		
		let newColor = deriveColor()
		if color != newColor {
			color = newColor
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
		
		let newTouchedAt = deriveTouchedAt()
		if touchedAt != newTouchedAt {
			touchedAt = newTouchedAt
			dirty = true
		}
		
		if dirty {
			notifyObservers()
		}
	}
	
	private func derivePower() -> Bool {
		for light in lights.filter({ $0.connected }) {
			if light.power {
				return true
			}
		}
		return false
	}
	
	private func deriveTouchedAt() -> Date {
		var derivedTouchedAt = self.touchedAt
		for light in lights {
			let lightTouchedAt = light.touchedAt
            if lightTouchedAt.timeIntervalSince(Date()) < 0 {
                derivedTouchedAt = lightTouchedAt as Date
            }
		}
		
		return derivedTouchedAt
	}
	
	private func deriveBrightness() -> Double {
		let connectedLights = lights.filter { $0.connected }
        if connectedLights.count > 0 {
            return connectedLights.reduce(0.0, { $1.brightness + $0 }) / Double(connectedLights.count)
		} else {
			return 0.0
		}
	}
	
	private func deriveColor() -> Color {
        let connectedLights = lights.filter { $0.connected }
        if connectedLights.count > 1 {
			var hueXTotal: Double = 0.0
			var hueYTotal: Double = 0.0
			var saturationTotal: Double = 0.0
			var kelvinTotal: Int = 0
			for light in connectedLights {
				let color = light.color
				hueXTotal += sin(color.hue * 2.0 * .pi / Color.maxHue)
				hueYTotal += cos(color.hue * 2.0 * .pi / Color.maxHue)
				saturationTotal += color.saturation
				kelvinTotal += color.kelvin
			}
			var hue: Double = atan2(hueXTotal, hueYTotal) / (2.0 * .pi);
			if hue < 0.0 {
				hue += 1.0
			}
			hue *= Color.maxHue
            let saturation = saturationTotal / Double(connectedLights.count)
            let kelvin = kelvinTotal / connectedLights.count
			return Color(hue: hue, saturation: saturation, kelvin: kelvin)
        } else if let light = connectedLights.first, connectedLights.count == 1 {
			return light.color
		} else {
			return Color(hue: 0, saturation: 0, kelvin: Color.defaultKelvin)
		}
	}
	
	private func deriveLabel() -> String {
		switch selector.type {
		case .All:
			return "All"
		case .ID, .Label:
			return lights.first?.label ?? ""
		case .GroupID:
			if let group = lights.filter({ $0.group != nil }).first?.group {
				return group.name
			} else {
				return ""
			}
		case .LocationID:
			if let location = lights.filter({ $0.location != nil }).first?.location {
				return location.name
			} else {
				return ""
			}
		case .SceneID:
            if let index = client.scenes.firstIndex(where: { $0.toSelector() == selector }) {
				return client.scenes[index].name
			} else {
				return ""
			}
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
	
	public var supportsColor: Bool {
		return lights.map { $0.hasColor }.contains(true)
	}
	
	public var supportsIR: Bool {
		return lights.map { $0.hasIR }.contains(true)
	}

    public var supportsHEV: Bool {
        return lights.map { $0.hasHEV }.contains(true)
    }

	public var supportsMultiZone: Bool {
		return lights.map { $0.hasMultiZone }.contains(true)
	}
    
    public var supportsVariableColorTemp: Bool {
        return lights.contains(where: { $0.hasVariableColorTemp })
    }
}
