//
//  Created by Tate Johnson on 29/05/2015.
//  Copyright (c) 2015 Tate Johnson. All rights reserved.
//

import Foundation

public class Client {
	public let session: HTTPSession
	public private(set) var lights: [Light]
	public private(set) var scenes: [Scene]
	private var observers: [ClientObserver]
	
	public convenience init(accessToken: String, lights: [Light]? = nil, scenes: [Scene]? = nil) {
		self.init(session: HTTPSession(accessToken: accessToken), lights: lights, scenes: scenes)
	}
	
	public init(session: HTTPSession, lights: [Light]? = nil, scenes: [Scene]? = nil) {
		self.session = session
		self.lights = lights ?? []
		self.scenes = scenes ?? []
		observers = []
	}
	
	public func fetch(completionHandler: ((_ errors: [Error]) -> Void)? = nil) {
		let group = DispatchGroup()
		var errors: [Error] = []
		
		group.enter()
		fetchLights { (error) in
			if let error = error {
				errors.append(error)
			}
			group.leave()
		}
		
		group.enter()
		fetchScenes { (error) in
			if let error = error {
				errors.append(error)
			}
			group.leave()
		}
		
		group.notify(queue: session.delegateQueue) {
			completionHandler?(errors)
		}
	}
	
	public func fetchLights(completionHandler: ((_ error: Error?) -> Void)? = nil) {
		session.lights("all") { [weak self] (request, response, lights, error) in
			if error != nil {
				completionHandler?(error)
				return
			}
			
			if let strongSelf = self {
				let oldLights = strongSelf.lights
				let newLights = lights
				if oldLights != newLights {
					strongSelf.lights = newLights
					for observer in strongSelf.observers {
						observer.lightsDidUpdateHandler(lights)
					}
				}
				
			}
			
			completionHandler?(nil)
		}
	}
	
	public func fetchScenes(completionHandler: ((_ error: Error?) -> Void)? = nil) {
		session.scenes { [weak self] (request, response, scenes, error) in
			if error != nil {
				completionHandler?(error)
				return
			}
			
			self?.scenes = scenes
			
			completionHandler?(nil)
		}
	}
	
	public func allLightTarget() -> LightTarget {
		return lightTargetWithSelector(LightTargetSelector(type: .All))
	}
	
	public func lightTargetWithSelector(_ selector: LightTargetSelector) -> LightTarget {
		return LightTarget(client: self, selector: selector, filter: selectorToFilter(selector))
	}
	
	func addObserver(lightsDidUpdateHandler: @escaping ClientObserver.LightsDidUpdate) -> ClientObserver {
		let observer = ClientObserver(lightsDidUpdateHandler: lightsDidUpdateHandler)
		observers.append(observer)
		return observer
	}
	
	func removeObserver(observer: ClientObserver) {
		for (index, other) in observers.enumerated() {
			if other === observer {
				observers.remove(at: index)
				break
			}
		}
	}
	
	func updateLights(_ lights: [Light]) {
		let oldLights = self.lights
		var newLights: [Light] = []
		
		for light in lights {
			if !newLights.contains(where: { $0.id == light.id }) {
				newLights.append(light)
			}
		}
		for light in oldLights {
			if !newLights.contains(where: { $0.id == light.id }) {
				newLights.append(light)
			}
		}
		
		if oldLights != newLights {
			for observer in observers {
				observer.lightsDidUpdateHandler(newLights)
			}
			self.lights = newLights
		}
	}
	
	private func selectorToFilter(_ selector: LightTargetSelector) -> LightTargetFilter {
		switch selector.type {
		case .All:
			return { (light) in return true }
		case .ID:
			return { (light) in return light.id == selector.value }
		case .GroupID:
			return { (light) in return light.group?.id == selector.value }
		case .LocationID:
			return { (light) in return light.location?.id == selector.value }
		case .SceneID:
			return { [weak self] (light) in
				if let strongSelf = self, let index = strongSelf.scenes.index(where: { $0.toSelector() == selector }) {
					let scene = strongSelf.scenes[index]
					return scene.states.contains { (state) in
						let filter = strongSelf.selectorToFilter(state.selector)
						return filter(light)
					}
				} else {
					return false
				}
			}
		case .Label:
			return { (light) in return light.label == selector.value }
		}
	}
}
