//
//  Client.swift
//  LIFXHTTPKit
//
//  Created by Tate Johnson on 29/05/2015.
//  Copyright (c) 2015 Tate Johnson. All rights reserved.
//

import Foundation

public let ErrorDomain: String = "LIFXHTTPKitErrorDomain"

public enum ErrorCode: Int {
	case JSONInvalid
}

internal class ClientObserver {
	internal typealias LightsDidUpdate = (lights: [Light]) -> Void

	internal let lightsDidUpdate: LightsDidUpdate

	init(closure: LightsDidUpdate) {
		self.lightsDidUpdate = closure
	}
}

public class Client {
	private let session: HTTPSession
	private var lights: [Light]
	private var observers: [ClientObserver]

	public init(accessToken: String) {
		session = HTTPSession(accessToken: accessToken)
		lights = []
		observers = []
	}

	internal func addObserver(closure: ClientObserver.LightsDidUpdate) -> ClientObserver {
		let observer = ClientObserver(closure: closure)
		observers.append(observer)
		return observer
	}

	internal func removeObserver(observer: ClientObserver) {
		for (index, other) in enumerate(observers) {
			if other === observer {
				observers.removeAtIndex(index)
				break
			}
		}
	}

	public func discover() {
		session.lights(selector: "all") { [unowned self] (request, response, lights, error) in
			if error != nil {
				println("Client: Discovery did fail. See \(error)")
				return
			}

			let oldLights = self.lights
			let newLights = lights
			if oldLights != newLights {
				self.lights = newLights
				for observer in self.observers {
					observer.lightsDidUpdate(lights: lights)
				}
			}
		}
	}

	public func allLights() -> LightTarget {
		return LightTarget(client: self, filter: { (light) in return true })
	}

	public func allGroups() -> [LightTarget] {
		return []
	}

	public func allLocations() -> [LightTarget] {
		return []
	}
}

public class LightTargetObserver {
	public typealias StateDidUpdate = () -> Void

	internal let stateDidUpdate: StateDidUpdate

	init(closure: StateDidUpdate) {
		self.stateDidUpdate = closure
	}
}

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

	public func addObserver(closure: LightTargetObserver.StateDidUpdate) -> LightTargetObserver {
		let observer = LightTargetObserver(closure: closure)
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
				observer.stateDidUpdate()
			}
		}
	}
}

public class HTTPSession {
	private let accessToken: String
	private let baseURL: NSURL
	private let userAgent: String
	private let session: NSURLSession

	public init(accessToken: String, baseURL: NSURL = NSURL(string: "https://api.lifx.com/v1beta1/")!, userAgent: String = "LIFXHTTPKit/0.0.1") {
		self.accessToken = accessToken
		self.baseURL = baseURL
		self.userAgent = userAgent
		session = NSURLSession.sharedSession()
	}

	public func lights(selector: String = "all", completionHander: ((request: NSURLRequest, response: NSURLResponse?, lights: [Light], error: NSError?) -> Void)) {
		let url = baseURL.URLByAppendingPathComponent("/lights/\(selector)")
		let request = NSMutableURLRequest(URL: url)
		request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
		request.setValue("application/json", forHTTPHeaderField: "Accept")
		request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
		session.dataTaskWithRequest(request) { (data, response, error) in
			if error != nil {
				completionHander(request: request, response: response, lights: [], error: error)
			} else {
				let deserialized = self.dataToLights(data)
				completionHander(request: request, response: response, lights: deserialized.lights, error: deserialized.error)
			}
		}.resume()
	}

	private func dataToLights(data: NSData) -> (lights: [Light], error: NSError?) {
		var error: NSError?
		let rootJSONObject: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: .allZeros, error: &error)

		if error != nil {
			return ([], error)
		}

		var lightJSONObjects: [NSDictionary] = []
		if let dictionary = rootJSONObject as? NSDictionary {
			lightJSONObjects = [dictionary]
		} else if let array = rootJSONObject as? [NSDictionary] {
			lightJSONObjects = array
		}

		var lights: [Light] = []
		for lightJSONObject in lightJSONObjects {
			if let id = lightJSONObject["id"] as? String, label = lightJSONObject["label"] as? String, power = lightJSONObject["power"] as? String, brightness = lightJSONObject["brightness"] as? Double {
				let light = Light(id: id, label: label, power: power == "on", brightness: brightness)
				lights.append(light)
			} else {
				return ([], NSError(domain: ErrorDomain, code: ErrorCode.JSONInvalid.rawValue, userInfo: [NSLocalizedDescriptionKey: "JSON object is missing required properties"]))
			}
		}
		return (lights, nil)
	}

	private func dataToResults(data: NSData) -> (results: [Result], error: NSError?) {
		return ([], nil)
	}
}

public struct Light: Equatable {
	public let id: String
	public let label: String
	public let power: Bool
	public let brightness: Double
}

public func ==(lhs: Light, rhs: Light) -> Bool {
	return lhs.id == rhs.id &&
		lhs.label == rhs.label &&
		lhs.power == rhs.power &&
		lhs.brightness == rhs.brightness
}

public struct Result: Equatable {
	public enum Status {
		case OK
		case TimedOut
		case Offline
	}

	public let id: String
	public let status: Status
}

public func ==(lhs: Result, rhs: Result) -> Bool {
	return lhs.id == rhs.id && lhs.status == rhs.status
}
