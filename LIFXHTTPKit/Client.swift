//
//  Created by Tate Johnson on 29/05/2015.
//  Copyright (c) 2015 Tate Johnson. All rights reserved.
//

import Foundation

public class Client {
	internal let session: HTTPSession
	private var lights: [Light]
	private var observers: [ClientObserver]

	public init(accessToken: String) {
		session = HTTPSession(accessToken: accessToken)
		lights = []
		observers = []
	}

	public func fetch(completionHandler: ((error: NSError?) -> Void)? = nil) {
		session.lights(selector: "all") { [unowned self] (request, response, lights, error) in
			if error != nil {
				completionHandler?(error: error)
				return
			}

			let oldLights = self.lights
			let newLights = lights
			if oldLights != newLights {
				self.lights = newLights
				for observer in self.observers {
					observer.lightsDidUpdateHandler(lights: lights)
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

	internal func addObserver(lightsDidUpdateHandler: ClientObserver.LightsDidUpdate) -> ClientObserver {
		let observer = ClientObserver(lightsDidUpdateHandler: lightsDidUpdateHandler)
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

	internal func updateLightsWithLights(lights: [Light]) {
		let oldLights = self.lights
		let newLights = oldLights.map { (oldLight) -> Light in
			for newLight in lights {
				if oldLight.id == newLight.id && oldLight != newLight {
					return newLight
				}
			}
			return oldLight
		}

		if oldLights != newLights {
			for observer in observers {
				observer.lightsDidUpdateHandler(lights: self.lights)
			}
		}
	}

	internal func getLights() -> [Light] {
		return lights
	}
}
