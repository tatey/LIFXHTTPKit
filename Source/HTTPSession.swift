//
//  Created by Tate Johnson on 13/06/2015.
//  Copyright (c) 2015 Tate Johnson. All rights reserved.
//

import Foundation

public class HTTPSession {
	public static let defaultBaseURL: URL = URL(string: "https://api.lifx.com/v1/")!
	public static let defaultUserAgent: String = "LIFXHTTPKit/\(LIFXHTTPKitVersionNumber)"
	public static let defaultTimeout: TimeInterval = 5.0
	
	public let baseURL: URL
	public let delegateQueue: DispatchQueue
	public let URLSession: Foundation.URLSession
	
	private let operationQueue: OperationQueue
	
	public init(accessToken: String, delegateQueue: DispatchQueue = DispatchQueue(label: "com.tatey.lifx-http-kit.http-session", attributes: []), baseURL: URL = HTTPSession.defaultBaseURL, userAgent: String = HTTPSession.defaultUserAgent, timeout: TimeInterval = HTTPSession.defaultTimeout) {
		self.baseURL = baseURL
		self.delegateQueue = delegateQueue
		
		let configuration = URLSessionConfiguration.default
		configuration.httpAdditionalHeaders = ["Authorization": "Bearer \(accessToken)", "Accept": "appplication/json", "User-Agent": userAgent]
		configuration.timeoutIntervalForRequest = timeout
		URLSession = Foundation.URLSession(configuration: configuration)
		
		operationQueue = OperationQueue()
		operationQueue.maxConcurrentOperationCount = 1
	}
	
	public func lights(_ selector: String = "all", completionHandler: @escaping ((_ request: URLRequest, _ response: URLResponse?, _ lights: [Light], _ error: Error?) -> Void)) {
		var request = URLRequest(url: baseURL.appendingPathComponent("lights/\(selector)"))
		request.httpMethod = "GET"
		addOperationWithRequest(request as URLRequest) { (data, response, error) in
			if let error = error ?? self.validateResponseWithExpectedStatusCodes(response, statusCodes: [200]) {
				completionHandler(request as URLRequest, response, [], error)
			} else {
				let (lights, error) = self.dataToLights(data)
				completionHandler(request, response, lights, error)
			}
		}
	}
	
	public func setLightsPower(_ selector: String, power: Bool, duration: Float, completionHandler: @escaping ((_ request: URLRequest, _ response: URLResponse?, _ results: [Result], _ error: Error?) -> Void)) {
		print("`setLightsPower:power:duration:completionHandler:` is deprecated and will be removed in a future version. Use `setLightsState:power:color:brightness:duration:completionHandler:` instead.")
		setLightsState(selector, power: power, duration: duration, completionHandler: completionHandler)
	}
	
	public func setLightsColor(_ selector: String, color: String, duration: Float, powerOn: Bool, completionHandler: @escaping ((_ request: URLRequest, _ response: URLResponse?, _ results: [Result], _ error: Error?) -> Void)) {
		print("`setLightsColor:color:duration:powerOn:completionHandler:` is deprecated and will be removed in a future version. Use `setLightsState:power:color:brightness:duration:completionHandler:` instead.")
		setLightsState(selector, power: powerOn, color: color, duration: duration, completionHandler: completionHandler)
	}
	
	public func setLightsState(_ selector: String, power: Bool? = nil, color: String? = nil, brightness: Double? = nil, duration: Float, completionHandler: @escaping ((_ request: URLRequest, _ response: URLResponse?, _ results: [Result], _ error: Error?) -> Void)) {
		var request = URLRequest(url: baseURL.appendingPathComponent("lights/\(selector)/state"))
		var parameters: [String : Any] = ["duration": duration as AnyObject]
		if let power = power {
			parameters["power"] = power ? "on" : "off" as AnyObject?
		}
		if let color = color {
			parameters["color"] = color as AnyObject?
		}
		if let brightness = brightness {
			parameters["brightness"] = brightness as AnyObject?
		}
		request.httpMethod = "PUT"
		request.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: [])
		request.setValue("application/json", forHTTPHeaderField: "Content-Type")
		addOperationWithRequest(request as URLRequest) { (data, response, error) in
			if let error = error ?? self.validateResponseWithExpectedStatusCodes(response, statusCodes: [200, 207]) {
				completionHandler(request as URLRequest, response, [], error)
			} else {
				let (results, error) = self.dataToResults(data)
				completionHandler(request, response, results, error)
			}
		}
	}
	
	public func scenes(_ completionHandler: @escaping ((_ request: URLRequest, _ response: URLResponse?, _ scenes: [Scene], _ error: Error?) -> Void)) {
		var request = URLRequest(url: baseURL.appendingPathComponent("scenes"))
		request.httpMethod = "GET"
		addOperationWithRequest(request as URLRequest) { (data, response, error) in
			if let error = error ?? self.validateResponseWithExpectedStatusCodes(response, statusCodes: [200]) {
				completionHandler(request as URLRequest, response, [], error)
			} else {
				let (scenes, error) = self.dataToScenes(data)
				completionHandler(request, response, scenes, error)
			}
		}
	}
	
	public func setScenesActivate(_ selector: String, duration: Float, completionHandler: @escaping ((_ request: URLRequest, _ response: URLResponse?, _ results: [Result], _ error: Error?) -> Void)) {
		var request = URLRequest(url: baseURL.appendingPathComponent("scenes/\(selector)/activate"))
		let parameters = ["duration", duration] as [Any]
		request.httpMethod = "PUT"
		request.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: [])
		addOperationWithRequest(request as URLRequest) { (data, response, error) in
			if let error = error ?? self.validateResponseWithExpectedStatusCodes(response, statusCodes: [200, 207]) {
				completionHandler(request as URLRequest, response, [], error)
			} else {
				let (results, error) = self.dataToResults(data)
				completionHandler(request, response, results, error)
			}
		}
	}
	
	// MARK: Helpers
	
	private func addOperationWithRequest(_ request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
		let operation = HTTPOperation(URLSession: URLSession, delegateQueue: delegateQueue, request: request, completionHandler: completionHandler)
		operationQueue.operations.first?.addDependency(operation)
		operationQueue.addOperation(operation)
	}
	
	private func validateResponseWithExpectedStatusCodes(_ response: URLResponse?, statusCodes: [Int]) -> Error? {
		guard let response = response as? HTTPURLResponse else {
			return nil
		}
		
		if statusCodes.contains(response.statusCode) {
			return nil
		}
		
		switch (response.statusCode) {
		case 401:
			return HTTPKitError(code: .unauthorized, message: "Bad access token")
		case 403:
			return HTTPKitError(code: .forbidden, message: "Permission denied")
		case 429:
			return HTTPKitError(code: .tooManyRequests, message: "Rate limit exceeded")
		case 500, 502, 503, 523:
			return HTTPKitError(code: .unauthorized, message: "Server error")
		default:
			return HTTPKitError(code: .unexpectedHTTPStatusCode, message: "Expecting \(statusCodes), got \(response.statusCode)")
		}
	}
	
	private func dataToLights(_ data: Data?) -> (lights: [Light], error: Error?) {
		guard let data = data else {
			return ([], HTTPKitError(code: .jsonInvalid, message: "No data"))
		}
		
		let rootJSONObject: Any?
		do {
			rootJSONObject = try JSONSerialization.jsonObject(with: data, options: [])
		} catch let error {
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
				let power = lightJSONObject["power"] as? String,
				let brightness = lightJSONObject["brightness"] as? Double,
				let colorJSONObject = lightJSONObject["color"] as? NSDictionary,
				let colorHue = colorJSONObject["hue"] as? Double,
				let colorSaturation = colorJSONObject["saturation"] as? Double,
				let colorKelvin = colorJSONObject["kelvin"] as? Int,
				let label = lightJSONObject["label"] as? String,
				let connected = lightJSONObject["connected"] as? Bool {
				let group: Group?
				if let groupJSONObject = lightJSONObject["group"] as? NSDictionary,
					let groupId = groupJSONObject["id"] as? String,
					let groupName = groupJSONObject["name"] as? String {
					group = Group(id: groupId, name: groupName)
				} else {
					group = nil
				}
				
				let location: Location?
				if let locationJSONObject = lightJSONObject["location"] as? NSDictionary,
					let locationId = locationJSONObject["id"] as? String,
					let locationName = locationJSONObject["name"] as? String {
					location = Location(id: locationId, name: locationName)
				} else {
					location = nil
				}
                
				var productInformation: ProductInformation?
				if let productInformationJSONObject = lightJSONObject["product"] as? NSDictionary {
					productInformation = ProductInformation(data: productInformationJSONObject)
				}
				
				let color = Color(hue: colorHue, saturation: colorSaturation, kelvin: colorKelvin)
				let light = Light(id: id, power: power == "on", brightness: brightness, color: color, productInfo: productInformation, label: label, connected: connected, group: group, location: location, touchedAt: Date())
				lights.append(light)
			} else {
				return ([], HTTPKitError(code: .jsonInvalid, message: "JSON object is missing required properties"))
			}
		}
		return (lights, nil)
	}
	
	private func dataToScenes(_ data: Data?) -> (scenes: [Scene], error: Error?) {
		guard let data = data else {
			return ([], HTTPKitError(code: .jsonInvalid, message: "No data"))
		}
		
		let rootJSONObject: Any?
		do {
			rootJSONObject = try JSONSerialization.jsonObject(with: data, options: [])
		} catch let error {
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
				let name = sceneJSONObject["name"] as? String,
				let stateJSONObjects = sceneJSONObject["states"] as? [NSDictionary] {
				var states: [State] = []
				for stateJSONObject in stateJSONObjects {
					if let rawSelector = stateJSONObject["selector"] as? String,
						let selector = LightTargetSelector(stringValue: rawSelector) {
						let brightness = stateJSONObject["brightness"] as? Double ?? nil
						let color: Color?
						if let colorJSONObject = stateJSONObject["color"] as? NSDictionary,
							let colorHue = colorJSONObject["hue"] as? Double,
							let colorSaturation = colorJSONObject["saturation"] as? Double,
							let colorKelvin = colorJSONObject["kelvin"] as? Int {
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
	
	private func dataToResults(_ data: Data?) -> (results: [Result], error: Error?) {
		guard let data = data else {
			return ([], HTTPKitError(code: .jsonInvalid, message: "No data"))
		}
		
		let rootJSONObject: Any
		do {
			rootJSONObject = try JSONSerialization.jsonObject(with: data, options: [])
		} catch let error {
			return ([], error)
		}
		
		let resultJSONObjects: [NSDictionary]
		if let dictionary = rootJSONObject as? NSDictionary, let array = dictionary["results"] as? [NSDictionary] {
			resultJSONObjects = array
		} else {
			resultJSONObjects = []
		}
		
		var results: [Result] = []
		for resultJSONObject in resultJSONObjects {
			if let id = resultJSONObject["id"] as? String, let status =  Result.Status(rawValue: resultJSONObject["status"] as? String ?? "unknown") {
				let result = Result(id: id, status: status)
				results.append(result)
			} else {
				return ([], HTTPKitError(code: .jsonInvalid, message: "JSON object is missing required properties"))
			}
		}
		
		return (results, nil)
	}
}
