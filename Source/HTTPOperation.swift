//
//  Created by Tate Johnson on 16/10/2015.
//  Copyright © 2015 Tate Johnson. All rights reserved.
//

import Foundation

public class HTTPOperationState {
	public var cancelled: Bool
	public var executing: Bool
	public var finished: Bool
	
	public init() {
		cancelled = false
		executing = false
		finished = false
	}
}

public class HTTPOperation: Operation {
	private let state: HTTPOperationState
	private let delegateQueue: DispatchQueue
	private var task: URLSessionDataTask?
	
	public init(session: URLSession, delegateQueue: DispatchQueue, request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
		state = HTTPOperationState()
		self.delegateQueue = delegateQueue
		
		super.init()
		
		task = session.dataTask(with: request, completionHandler: { [weak self] (data, response, error) in
			if let strongSelf = self {
				strongSelf.isExecuting = false
				strongSelf.isFinished = true
				strongSelf.delegateQueue.async {
					completionHandler(data, response, error as NSError?)
				}
			}
		})
	}
	
	override public var isAsynchronous: Bool {
		return true
	}
	
	override private(set) public var isCancelled: Bool {
		get { return state.cancelled }
		set {
			willChangeValue(forKey: "isCancelled")
			state.cancelled = newValue
			didChangeValue(forKey: "isCancelled")
		}
	}
	
	override private(set) public var isExecuting: Bool {
		get { return state.executing }
		set {
			willChangeValue(forKey: "isExecuting")
			state.executing = newValue
			didChangeValue(forKey: "isExecuting")
		}
	}
	
	override private(set) public var isFinished: Bool {
		get { return state.finished }
		set {
			willChangeValue(forKey: "isFinished")
			state.finished = newValue
			didChangeValue(forKey: "isFinished")
		}
	}
	
	override public func start() {
		if isCancelled {
			return
		}
		
		task?.resume()
		isExecuting = true
	}
	
	override public func cancel() {
		task?.cancel()
		isCancelled = true
	}
}
