//
//  Client.swift
//  LIFXHTTPKit
//
//  Created by Tate Johnson on 29/05/2015.
//  Copyright (c) 2015 Tate Johnson. All rights reserved.
//

import Foundation

public class Client {
	private let session: HTTPSession
	private var lights: [Light]
	private var observers: [LightTarget]

	public init(accessToken: String) {
		session = HTTPSession(accessToken: accessToken)
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
		return LightTarget(client: self, filter: { (light) in return true })
	}

	public func allGroups() -> [LightTarget] {
		return []
	}

	public func allLocations() -> [LightTarget] {
		return []
	}
}

public class LightTarget {
	public typealias Filter = (light: Light) -> Bool

	public var power: Bool
	public var brightness: Float

	private unowned var client: Client
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
		client.removeObserver(self)
	}

	internal func setLights(lights: [Light]) {
		self.lights = lights.filter(filter)
	}

	public func toLights() -> [Light] {
		return lights
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

	public func lights(selector: String = "all", completionHander: ((request: NSURLRequest, response: NSURLResponse, lights: [Light], error: NSError?) -> Void)) {
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
		}
	}

	private func dataToLights(data: NSData) -> (lights: [Light], error: NSError?) {
		return ([], nil)
	}

	private func dataToResults(data: NSData) -> (results: [Result], error: NSError?) {
		return ([], nil)
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
