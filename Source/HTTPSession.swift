//
//  Created by Tate Johnson on 13/06/2015.
//  Copyright (c) 2015 Tate Johnson. All rights reserved.
//

import Foundation

public class HTTPSession {
	public static let defaultBaseURL: NSURL = NSURL(string: "https://api.lifx.com/v1beta1/")!
	public static let defaultUserAgent: String = "LIFXHTTPKit/\(LIFXHTTPKitVersionNumber)"

	private let accessToken: String
	private let baseURL: NSURL
	private let userAgent: String
	private let session: NSURLSession

	public init(accessToken: String, baseURL: NSURL = HTTPSession.defaultBaseURL, userAgent: String = HTTPSession.defaultUserAgent, session: NSURLSession = NSURLSession.sharedSession()) {
		self.accessToken = accessToken
		self.baseURL = baseURL
		self.userAgent = userAgent
		self.session = session
	}

	public func lights(selector: String = "all", completionHandler: ((request: NSURLRequest, response: NSURLResponse?, lights: [Light], error: NSError?) -> Void)) {
		let request = requestWithBaseURLByAppendingPathComponent("/lights/\(selector)")
		request.HTTPMethod = "GET"
		session.dataTaskWithRequest(request) { (data, response, error) in
			dispatch_async(dispatch_get_main_queue()) {
				if error != nil {
					completionHandler(request: request, response: response, lights: [], error: error)
				} else {
					let deserialized = self.dataToLights(data)
					completionHandler(request: request, response: response, lights: deserialized.lights, error: deserialized.error)
				}
			}
		}.resume()
	}

	public func setLightsPower(selector: String, power: Bool, duration: Float, completionHandler: ((request: NSURLRequest, response: NSURLResponse?, results: [Result], error: NSError?) -> Void)) {
		let request = requestWithBaseURLByAppendingPathComponent("/lights/\(selector)/power")
		let parameters = ["state": power ? "on" : "off", "duration": duration]
		request.HTTPMethod = "PUT"
		request.HTTPBody = NSJSONSerialization.dataWithJSONObject(parameters, options: .allZeros, error: nil)
		request.setValue("application/json", forHTTPHeaderField: "Content-Type")
		session.dataTaskWithRequest(request) { (data, response, error) in
			dispatch_async(dispatch_get_main_queue()) {
				if error != nil {
					completionHandler(request: request, response: response, results: [], error: error)
				} else {
					let deserialized = self.dataToResults(data)
					completionHandler(request: request, response: response, results: deserialized.results, error: deserialized.error)
				}
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

	private func dataToLights(data: NSData) -> (lights: [Light], error: NSError?) {
		var error: NSError?
		let rootJSONObject: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: .allZeros, error: &error)

		if error != nil {
			return ([], error)
		}

		var lightJSONObjects: [NSDictionary]
		if let dictionary = rootJSONObject as? NSDictionary {
			lightJSONObjects = [dictionary]
		} else if let array = rootJSONObject as? [NSDictionary] {
			lightJSONObjects = array
		} else {
			lightJSONObjects = []
		}

		var lights: [Light] = []
		for lightJSONObject in lightJSONObjects {
			if let id = lightJSONObject["id"] as? String, label = lightJSONObject["label"] as? String, power = lightJSONObject["power"] as? String, brightness = lightJSONObject["brightness"] as? Double, connected = lightJSONObject["connected"] as? Bool {
				let light = Light(id: id, label: label, power: power == "on", brightness: brightness, connected: connected)
				lights.append(light)
			} else {
				return ([], NSError(domain: ErrorDomain, code: ErrorCode.JSONInvalid.rawValue, userInfo: [NSLocalizedDescriptionKey: "JSON object is missing required properties"]))
			}
		}
		return (lights, nil)
	}

	private func dataToResults(data: NSData) -> (results: [Result], error: NSError?) {
		var error: NSError?
		let rootJSONObject: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: .allZeros, error: &error)

		if error != nil {
			return ([], error)
		}

		var resultJSONObjects: [NSDictionary]
		if let dictionary = rootJSONObject as? NSDictionary {
			resultJSONObjects = [dictionary]
		} else if let array = rootJSONObject as? [NSDictionary] {
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
