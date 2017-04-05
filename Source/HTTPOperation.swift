//
//  Created by Tate Johnson on 16/10/2015.
//  Copyright © 2015 Tate Johnson. All rights reserved.
//

import Foundation

class HTTPOperationState {
	var cancelled: Bool
	var executing: Bool
	var finished: Bool
	
	init() {
		cancelled = false
		executing = false
		finished = false
	}
}

class HTTPOperation: Operation {
	private let state: HTTPOperationState
	private let delegateQueue: DispatchQueue
	private var task: URLSessionDataTask?
	
	init(URLSession: Foundation.URLSession, delegateQueue: DispatchQueue, request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
		state = HTTPOperationState()
		self.delegateQueue = delegateQueue
		
		super.init()
		
		task = URLSession.dataTask(with: request, completionHandler: { [weak self] (data, response, error) in
			if let strongSelf = self {
				strongSelf.isExecuting = false
				strongSelf.isFinished = true
				strongSelf.delegateQueue.async {
					completionHandler(data, response, error as NSError?)
				}
			}
		})
	}
	
	override var isAsynchronous: Bool {
		return true
	}
	
	override private(set) var isCancelled: Bool {
		get { return state.cancelled }
		set {
			willChangeValue(forKey: "isCancelled")
			state.cancelled = newValue
			didChangeValue(forKey: "isCancelled")
		}
	}
	
	override private(set) var isExecuting: Bool {
		get { return state.executing }
		set {
			willChangeValue(forKey: "isExecuting")
			state.executing = newValue
			didChangeValue(forKey: "isExecuting")
		}
	}
	
	override private(set) var isFinished: Bool {
		get { return state.finished }
		set {
			willChangeValue(forKey: "isFinished")
			state.finished = newValue
			didChangeValue(forKey: "isFinished")
		}
	}
	
	override func start() {
		if isCancelled {
			return
		}
		
		task?.resume()
		isExecuting = true
	}
	
	override func cancel() {
		task?.cancel()
		isCancelled = true
	}
}
