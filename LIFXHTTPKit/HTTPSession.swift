//
//  Created by Tate Johnson on 13/06/2015.
//  Copyright (c) 2015 Tate Johnson. All rights reserved.
//

import Foundation

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
