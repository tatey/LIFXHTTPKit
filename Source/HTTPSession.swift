//
//  Created by Tate Johnson on 13/06/2015.
//  Copyright (c) 2015 Tate Johnson. All rights reserved.
//

import Foundation

public class HTTPSession {
	public static let defaultBaseURL: NSURL = NSURL(string: "https://api.lifx.com/v1/")!
	public static let defaultUserAgent: String = "LIFXHTTPKit/\(LIFXHTTPKitVersionNumber)"
	public static let defaultTimeoutIntervalForRequest: NSTimeInterval = 5.0

	private let accessToken: String
	private let baseURL: NSURL
	private let userAgent: String
	private let session: NSURLSession

	public init(accessToken: String, baseURL: NSURL = HTTPSession.defaultBaseURL, userAgent: String = HTTPSession.defaultUserAgent) {
		self.accessToken = accessToken
		self.baseURL = baseURL
		self.userAgent = userAgent

		let underlyingQueue = dispatch_queue_create("com.tatey.lifx-http-kit.http-session", DISPATCH_QUEUE_SERIAL)
		let operationQueue = NSOperationQueue()
		operationQueue.underlyingQueue = underlyingQueue
		let config = NSURLSessionConfiguration.defaultSessionConfiguration()
		config.timeoutIntervalForRequest = HTTPSession.defaultTimeoutIntervalForRequest
		session = NSURLSession(configuration: config, delegate: nil, delegateQueue: operationQueue)
	}

	public func lights(selector: String = "all", completionHandler: ((request: NSURLRequest, response: NSURLResponse?, lights: [Light], error: NSError?) -> Void)) {
		let request = requestWithBaseURLByAppendingPathComponent("/lights/\(selector)")
		request.HTTPMethod = "GET"
		session.dataTaskWithRequest(request) { (data, response, error) in
			if error != nil {
				completionHandler(request: request, response: response, lights: [], error: error)
			} else {
				let (lights, error) = self.dataToLights(data)
				completionHandler(request: request, response: response, lights: lights, error: error)
			}
		}.resume()
	}

	public func setLightsPower(selector: String, power: Bool, duration: Float, completionHandler: ((request: NSURLRequest, response: NSURLResponse?, results: [Result], error: NSError?) -> Void)) {
		print("`setLightsPower:power:duration:completionHandler:` is deprecated and will be removed in a future version. Use `setLightsState:power:color:brightness:duration:completionHandler:` instead.")
		setLightsState(selector, power: power, duration: duration, completionHandler: completionHandler)
	}

	public func setLightsColor(selector: String, color: String, duration: Float, powerOn: Bool, completionHandler: ((request: NSURLRequest, response: NSURLResponse?, results: [Result], error: NSError?) -> Void)) {
		print("`setLightsColor:color:duration:powerOn:completionHandler:` is deprecated and will be removed in a future version. Use `setLightsState:power:color:brightness:duration:completionHandler:` instead.")
		setLightsState(selector, color: color, power: powerOn, duration: duration, completionHandler: completionHandler)
	}

	public func setLightsState(selector: String, power: Bool? = nil, color: String? = nil, brightness: Double? = nil, duration: Float, completionHandler: ((request: NSURLRequest, response: NSURLResponse?, results: [Result], error: NSError?) -> Void)) {
		let request = requestWithBaseURLByAppendingPathComponent("/lights/\(selector)/state")
		var parameters: [String : AnyObject] = ["duration": duration]
		if let power = power {
			parameters["power"] = power ? "on" : "off"
		}
		if let color = color {
			parameters["color"] = color
		}
		if let brightness = brightness {
			parameters["brightness"] = brightness
		}
		request.HTTPMethod = "PUT"
		request.HTTPBody = try? NSJSONSerialization.dataWithJSONObject(parameters, options: [])
		request.setValue("application/json", forHTTPHeaderField: "Content-Type")
		session.dataTaskWithRequest(request) { (data, response, error) in
			if error != nil {
				completionHandler(request: request, response: response, results: [], error: error)
			} else {
				let (results, error) = self.dataToResults(data)
				completionHandler(request: request, response: response, results: results, error: error)
			}
		}.resume()
	}

	public func scenes(completionHandler: ((request: NSURLRequest, response: NSURLResponse?, scenes: [Scene], error: NSError?) -> Void)) {
		let request = requestWithBaseURLByAppendingPathComponent("/scenes")
		request.HTTPMethod = "GET"
		session.dataTaskWithRequest(request) { (data, response, error) in
			if error != nil {
				completionHandler(request: request, response: response, scenes: [], error: error)
			} else {
				let (scenes, error) = self.dataToScenes(data)
				completionHandler(request: request, response: response, scenes: scenes, error: error)
			}
		}.resume()
	}

	private func requestWithBaseURLByAppendingPathComponent(pathComponent: String) -> NSMutableURLRequest {
		let url = baseURL.URLByAppendingPathComponent(pathComponent)
		let request = NSMutableURLRequest(URL: url)
		request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
		request.setValue("application/json", forHTTPHeaderField: "Accept")
		request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
		return request
	}

	private func dataToLights(data: NSData?) -> (lights: [Light], error: NSError?) {
		guard let data = data else {
			return ([], NSError(domain: ErrorDomain, code: ErrorCode.JSONInvalid.rawValue, userInfo: [NSLocalizedDescriptionKey: "No Data"]))
		}

		let rootJSONObject: AnyObject?
		do {
			rootJSONObject = try NSJSONSerialization.JSONObjectWithData(data, options: [])
		} catch let error as NSError {
			return ([], error)
		}

		let lightJSONObjects: [NSDictionary]
		if let array = rootJSONObject as? [NSDictionary] {
			lightJSONObjects = array
		} else {
			lightJSONObjects = []
		}

		var lights: [Light] = []
		for lightJSONObject in lightJSONObjects {
			if let id = lightJSONObject["id"] as? String,
				power = lightJSONObject["power"] as? String,
				brightness = lightJSONObject["brightness"] as? Double,
				colorJSONObject = lightJSONObject["color"] as? NSDictionary,
				colorHue = colorJSONObject["hue"] as? Double,
				colorSaturation = colorJSONObject["saturation"] as? Double,
				colorKelvin = colorJSONObject["kelvin"] as? Int,
				label = lightJSONObject["label"] as? String,
				connected = lightJSONObject["connected"] as? Bool {
					let group: Group?
					if let groupJSONObject = lightJSONObject["group"] as? NSDictionary,
						groupId = groupJSONObject["id"] as? String,
						groupName = groupJSONObject["name"] as? String {
							group = Group(id: groupId, name: groupName)
					} else {
						group = nil
					}

					let location: Location?
					if let locationJSONObject = lightJSONObject["location"] as? NSDictionary,
						locationId = locationJSONObject["id"] as? String,
						locationName = locationJSONObject["name"] as? String {
							location = Location(id: locationId, name: locationName)
					} else {
						location = nil
					}

					let color = Color(hue: colorHue, saturation: colorSaturation, kelvin: colorKelvin)
					let light = Light(id: id, power: power == "on", brightness: brightness, color: color, label: label, connected: connected, group: group, location: location)
					lights.append(light)
			} else {
				return ([], NSError(domain: ErrorDomain, code: ErrorCode.JSONInvalid.rawValue, userInfo: [NSLocalizedDescriptionKey: "JSON object is missing required properties"]))
			}
		}
		return (lights, nil)
	}

	private func dataToScenes(data: NSData?) -> (scenes: [Scene], error: NSError?) {
		guard let data = data else {
			return ([], NSError(domain: ErrorDomain, code: ErrorCode.JSONInvalid.rawValue, userInfo: [NSLocalizedDescriptionKey: "No Data"]))
		}

		let rootJSONObject: AnyObject?
		do {
			rootJSONObject = try NSJSONSerialization.JSONObjectWithData(data, options: [])
		} catch let error as NSError {
			return ([], error)
		}

		let sceneJSONObjects: [NSDictionary]
		if let array = rootJSONObject as? [NSDictionary] {
			sceneJSONObjects = array
		} else {
			sceneJSONObjects = []
		}

		var scenes: [Scene] = []
		for sceneJSONObject in sceneJSONObjects {
			if let uuid = sceneJSONObject["uuid"] as? String,
				name = sceneJSONObject["name"] as? String,
				stateJSONObjects = sceneJSONObject["states"] as? [NSDictionary] {
				var states: [State] = []
				for stateJSONObject in stateJSONObjects {
					if let rawSelector = stateJSONObject["selector"] as? String,
						selector = LIFXHTTPKit.Selector(rawSelector: rawSelector) {
							let brightness = stateJSONObject["brightness"] as? Double ?? nil
							let color: Color?
							if let colorJSONObject = stateJSONObject["color"] as? NSDictionary,
								colorHue = colorJSONObject["hue"] as? Double,
								colorSaturation = colorJSONObject["saturation"] as? Double,
								colorKelvin = colorJSONObject["kelvin"] as? Int {
									color = Color(hue: colorHue, saturation: colorSaturation, kelvin: colorKelvin)
							} else {
								color = nil
							}
							let power: Bool?
							if let powerJSONValue = stateJSONObject["power"] as? String {
								power = powerJSONValue == "on"
							} else {
								power = nil
							}
							let state = State(selector: selector, brightness: brightness, color: color, power: power)
							states.append(state)
					}
				}
				let scene = Scene(uuid: uuid, name: name, states: states)
				scenes.append(scene)
			}
		}
		return (scenes, nil)
	}

	private func dataToResults(data: NSData?) -> (results: [Result], error: NSError?) {
		guard let data = data else {
			return ([], NSError(domain: ErrorDomain, code: ErrorCode.JSONInvalid.rawValue, userInfo: [NSLocalizedDescriptionKey: "No Data"]))
		}

		let rootJSONObject: AnyObject
		do {
			rootJSONObject = try NSJSONSerialization.JSONObjectWithData(data, options: [])
		} catch let error as NSError {
			return ([], error)
		}

		let resultJSONObjects: [NSDictionary]
		if let dictionary = rootJSONObject as? NSDictionary, array = dictionary["results"] as? [NSDictionary] {
			resultJSONObjects = array
		} else {
			resultJSONObjects = []
		}

		var results: [Result] = []
		for resultJSONObject in resultJSONObjects {
			if let id = resultJSONObject["id"] as? String, status =  Result.Status(rawValue: resultJSONObject["status"] as? String ?? "unknown") {
				let result = Result(id: id, status: status)
				results.append(result)
			} else {
				return ([], NSError(domain: ErrorDomain, code: ErrorCode.JSONInvalid.rawValue, userInfo: [NSLocalizedDescriptionKey: "JSON object is missing required properties"]))
			}
		}

		return (results, nil)
	}
}
