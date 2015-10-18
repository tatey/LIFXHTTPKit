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

class HTTPOperation: NSOperation {
	private let state: HTTPOperationState
	private let delegateQueue: dispatch_queue_t
	private var task: NSURLSessionDataTask?

	init(URLSession: NSURLSession, delegateQueue: dispatch_queue_t, request: NSURLRequest, completionHandler: (NSData?, NSURLResponse?, NSError?) -> Void) {
		state = HTTPOperationState()
		self.delegateQueue = delegateQueue

		super.init()

		task = URLSession.dataTaskWithRequest(request) { [weak self] (data, response, error) in
			if let strongSelf = self {
				strongSelf.executing = false
				strongSelf.finished = true
				dispatch_async(strongSelf.delegateQueue) {
					completionHandler(data, response, error)
				}
			}
		}
	}

	override var asynchronous: Bool {
		return true
	}

	override private(set) var cancelled: Bool {
		get { return state.cancelled }
		set {
			willChangeValueForKey("isCancelled")
			state.cancelled = newValue
			didChangeValueForKey("isCancelled")
		}
	}

	override private(set) var executing: Bool {
		get { return state.executing }
		set {
			willChangeValueForKey("isExecuting")
			state.executing = newValue
			didChangeValueForKey("isExecuting")
		}
	}

	override private(set) var finished: Bool {
		get { return state.finished }
		set {
			willChangeValueForKey("isFinished")
			state.finished = newValue
			didChangeValueForKey("isFinished")
		}
	}

	override func start() {
		if cancelled {
			return
		}

		task?.resume()
		executing = true
	}

	override func cancel() {
		task?.cancel()
		cancelled = true
	}
}
