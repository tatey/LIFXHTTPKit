//
//  Created by Tate Johnson on 29/05/2015.
//  Copyright (c) 2015 Tate Johnson. All rights reserved.
//

import Foundation

public class Client {
	private let session: HTTPSession
	private var lights: [Light]
	private var observers: [ClientObserver]

	public init(accessToken: String) {
		session = HTTPSession(accessToken: accessToken)
		lights = []
		observers = []
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
					observer.lightsDidUpdateHandler(lights: lights)
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
