//
//  Created by Tate Johnson on 13/06/2015.
//  Copyright (c) 2015 Tate Johnson. All rights reserved.
//

import Foundation

public class HTTPSession {
    
    // MARK: - Defaults
    
    public struct Defaults {
        public static let baseURL = URL(string: "https://api.lifx.com/v1/")!
        public static let userAgent = "LIFXHTTPKit/\(LIFXHTTPKitVersionNumber)"
        public static let timeout: TimeInterval = 5
    }
    
    // MARK: - Properties
	
	public let baseURL: URL
	public let delegateQueue: DispatchQueue
	public let session: URLSession
	
	private let operationQueue: OperationQueue
    private let log: Bool
    
    // MARK: - Lifecycle
	
    public init(accessToken: String, delegateQueue: DispatchQueue = DispatchQueue(label: "com.tatey.lifx-http-kit.http-session", attributes: []), baseURL: URL = Defaults.baseURL, userAgent: String = Defaults.userAgent, timeout: TimeInterval = Defaults.timeout, log: Bool = false) {
		self.baseURL = baseURL
		self.delegateQueue = delegateQueue
        self.log = log
		
		let configuration = URLSessionConfiguration.default
		configuration.httpAdditionalHeaders = ["Authorization": "Bearer \(accessToken)", "Accept": "appplication/json", "User-Agent": userAgent]
		configuration.timeoutIntervalForRequest = timeout
		session = URLSession(configuration: configuration)
		
		operationQueue = OperationQueue()
		operationQueue.maxConcurrentOperationCount = 1
	}
	
    /// Lists lights limited by `selector`.
    /// GET /lights/{selector}
	public func lights(_ selector: String = "all", completionHandler: @escaping ((_ request: URLRequest, _ response: URLResponse?, _ lights: [Light], _ error: Error?) -> Void)) {
        let request = HTTPRequest<EmptyRequest>(baseURL: baseURL, path: "lights/\(selector)")
        
        perform(request: request) { (response: HTTPResponse<[Light]>) in
            completionHandler(request.toURLRequest(), response.response, response.body ?? [], response.error)
        }
    }
	
    /// Sets `power`, `color` or `brightness` (or any combination) over a `duration`, limited by `selector`.
    /// PUT /lights/{selector}/state
	public func setLightsState(_ selector: String, power: Bool? = nil, color: String? = nil, brightness: Double? = nil, duration: Float, completionHandler: @escaping ((_ request: URLRequest, _ response: URLResponse?, _ results: [Result], _ error: Error?) -> Void)) {
        let body = StateRequest(power: power?.asPower, color: color, brightness: brightness, duration: duration)
        let request = HTTPRequest<StateRequest>(baseURL: baseURL, path: "lights/\(selector)/state", method: .put, headers: ["Content-Type": "application/json"], body: body, expectedStatusCodes: [200, 207])
        
        perform(request: request) { (response: HTTPResponse<Results>) in
            completionHandler(request.toURLRequest(), response.response, response.body?.results ?? [], response.error)
        }
	}
    
    /// Lists all scenes.
    /// GET /scenes
	public func scenes(_ completionHandler: @escaping ((_ request: URLRequest, _ response: URLResponse?, _ scenes: [Scene], _ error: Error?) -> Void)) {
        let request = HTTPRequest<EmptyRequest>(baseURL: baseURL, path: "scenes")
        
        perform(request: request) { (response: HTTPResponse<[Scene]>) in
            completionHandler(request.toURLRequest(), response.response, response.body ?? [], response.error)
        }
	}
	
    /// Activates a scene. The `duration` will override the duration stored on each scene device.
    /// PUT /scenes/{selector}/activate
	public func setScenesActivate(_ selector: String, duration: Float? = nil, completionHandler: @escaping ((_ request: URLRequest, _ response: URLResponse?, _ results: [Result], _ error: Error?) -> Void)) {
        let body = SceneRequest(duration: duration)
        let request = HTTPRequest<SceneRequest>(baseURL: baseURL, path: "scenes/\(selector)/activate", method: .put, headers: ["Content-Type": "application/json"], body: body, expectedStatusCodes: [200, 207])
        
        perform(request: request) { (response: HTTPResponse<Results>) in
            completionHandler(request.toURLRequest(), response.response, response.body?.results ?? [], response.error)
        }
	}
    
    /// List curated themes.
    /// GET https://cloud.lifx.com/themes/v1/curated
    public func curatedThemes(_ completionHandler: @escaping ((_ request: URLRequest, _ response: URLResponse?, _ themes: [Theme], _ error: Error?) -> Void)) {
        guard let curatedThemesURL = URL(string: "https://cloud.lifx.com/themes/v1/curated") else { return }
        let request = HTTPRequest<EmptyRequest>(baseURL: curatedThemesURL, path: nil)
        
        perform(request: request) { (response: HTTPResponse<[Theme]>) in
            completionHandler(request.toURLRequest(), response.response, response.body ?? [], response.error)
        }
    }
    
    /// Apply `theme` to `selector` over a `duration`.
    /// PUT /themes/{selector}
    public func applyTheme(_ selector: String, theme: String, duration: Float, completionHandler: @escaping ((_ request: URLRequest, _ response: URLResponse?, _ results: [Result], _ error: Error?) -> Void)) {
        let body = ThemeRequest(theme: theme, duration: duration)
        let request = HTTPRequest<ThemeRequest>(baseURL: baseURL, path: "themes/\(selector)", method: .put, headers: ["Content-Type": "application/json"], body: body, expectedStatusCodes: [200, 207])
        
        perform(request: request) { (response: HTTPResponse<Results>) in
            completionHandler(request.toURLRequest(), response.response, response.body?.results ?? [], response.error)
        }
    }
    
    // MARK: - Deprecated
    
    @available(*, deprecated, message: "Use `setLightsState:power:color:brightness:duration:completionHandler:` instead.")
    public func setLightsPower(_ selector: String, power: Bool, duration: Float, completionHandler: @escaping ((_ request: URLRequest, _ response: URLResponse?, _ results: [Result], _ error: Error?) -> Void)) {
        setLightsState(selector, power: power, duration: duration, completionHandler: completionHandler)
    }
    
    @available(*, deprecated, message: "Use `setLightsState:power:color:brightness:duration:completionHandler:` instead.")
    public func setLightsColor(_ selector: String, color: String, duration: Float, powerOn: Bool, completionHandler: @escaping ((_ request: URLRequest, _ response: URLResponse?, _ results: [Result], _ error: Error?) -> Void)) {
        setLightsState(selector, power: powerOn, color: color, duration: duration, completionHandler: completionHandler)
    }
	
	// MARK: Private Utils
    
    /// Performs an `HTTPRequest` with the given parameters and will complete with the an `HTTPResponse`.
    private func perform<R: Encodable, T: Decodable>(request: HTTPRequest<R>, completion: @escaping (HTTPResponse<T>) -> Void) {
        if log {
            print(request)
        }
        let operation = HTTPOperation(session: session, delegateQueue: delegateQueue, request: request.toURLRequest(), completionHandler: { (data, response, error) in
            let parsedError = error ?? self.validate(response: response, withExpectedStatusCodes: request.expectedStatusCodes)
            let wrapped = HTTPResponse<T>(data: data, response: response, error: parsedError)
            completion(wrapped)
            if self.log {
                print(wrapped)
            }
        })
        operationQueue.operations.first?.addDependency(operation)
        operationQueue.addOperation(operation)
    }
    
    /// Parses the `URLResponse` into any errors based on expected status codes.
    private func validate(response: URLResponse?, withExpectedStatusCodes codes: [Int]) -> Error? {
        guard let response = response as? HTTPURLResponse, !codes.contains(response.statusCode) else { return nil }
        return HTTPKitError(statusCode: response.statusCode) ?? HTTPKitError(code: .unexpectedHTTPStatusCode, message: "Expecting \(codes), got \(response.statusCode)")
    }
    
}
