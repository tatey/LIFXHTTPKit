//
//  Created by Tate Johnson on 29/05/2015.
//  Copyright (c) 2015 Tate Johnson. All rights reserved.
//

import Foundation

public class Client {
	let session: HTTPSession

	private(set) var lights: [Light]
	private var observers: [ClientObserver]

	public convenience init(accessToken: String) {
		let session = HTTPSession(accessToken: accessToken)
		self.init(session: session)
	}

	public init(session: HTTPSession) {
		self.session = session
		lights = []
		observers = []
	}

	public func fetch(completionHandler: ((error: NSError?) -> Void)? = nil) {
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
