//
//  Created by Tate Johnson on 29/05/2015.
//  Copyright (c) 2015 Tate Johnson. All rights reserved.
//

import Foundation

public class Client {
	let session: HTTPSession
	var lights: [Light]
	var scenes: [Scene]

	private var observers: [ClientObserver]
	private let queue: dispatch_queue_t

	public convenience init(accessToken: String) {
		let session = HTTPSession(accessToken: accessToken)
		self.init(session: session)
	}

	public init(session: HTTPSession) {
		self.session = session
		lights = []
		scenes = []
		observers = []
		queue = dispatch_queue_create("com.tatey.lifx-http-kit.client", DISPATCH_QUEUE_CONCURRENT)
	}

	public func fetch(completionHandler: ((errors: [NSError]) -> Void)? = nil) {
		let group = dispatch_group_create()
		var errors: [NSError] = []

		dispatch_group_enter(group)
		fetchLights { (error) in
			if let error = error {
				errors.append(error)
			}
			dispatch_group_leave(group)
		}

		dispatch_group_enter(group)
		fetchScenes { (error) in
			if let error = error {
				errors.append(error)
			}
			dispatch_group_leave(group)
		}

		dispatch_group_notify(group, queue) {
			completionHandler?(errors: errors)
		}
	}

	public func fetchLights(completionHandler: ((error: NSError?) -> Void)? = nil) {
		session.lights("all") { [weak self] (request, response, lights, error) in
			if error != nil {
				completionHandler?(error: error)
				return
			}

			if let strongSelf = self {
				let oldLights = strongSelf.lights
				let newLights = lights
				if oldLights != newLights {
					strongSelf.lights = newLights
					for observer in strongSelf.observers {
						observer.lightsDidUpdateHandler(lights: lights)
					}
				}

			}

			completionHandler?(error: nil)
		}
	}

	public func fetchScenes(completionHandler: ((error: NSError?) -> Void)? = nil) {
		session.scenes { [weak self] (request, response, scenes, error) in
			if error != nil {
				completionHandler?(error: error)
				return
			}

			self?.scenes = scenes

			completionHandler?(error: nil)
		}
	}

	public func allLightTarget() -> LightTarget {
		return lightTargetWithSelector(Selector(type: .All))
	}

	public func lightTargetWithSelector(selector: Selector) -> LightTarget {
		return LightTarget(client: self, selector: selector)
	}

	func addObserver(lightsDidUpdateHandler: ClientObserver.LightsDidUpdate) -> ClientObserver {
		let observer = ClientObserver(lightsDidUpdateHandler: lightsDidUpdateHandler)
		observers.append(observer)
		return observer
	}

	func removeObserver(observer: ClientObserver) {
		for (index, other) in observers.enumerate() {
			if other === observer {
				observers.removeAtIndex(index)
				break
			}
		}
	}

	func updateLights(lights: [Light]) {
		let oldLights = self.lights
		var newLights: [Light] = []

		for light in lights {
			if !newLights.contains({ $0.id == light.id }) {
				newLights.append(light)
			}
		}
		for light in oldLights {
			if !newLights.contains({ $0.id == light.id }) {
				newLights.append(light)
			}
		}

		if oldLights != newLights {
			for observer in observers {
				observer.lightsDidUpdateHandler(lights: newLights)
			}
			self.lights = newLights
		}
	}
}
