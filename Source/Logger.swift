//
//  Created by Tate Johnson on 14/10/2015.
//  Copyright © 2015 Tate Johnson. All rights reserved.
//

import Foundation

public enum LoggerMode {
	case Noop
	case Memory
	case Print
}

public class Logger {
	private var provider: LogProvider?

	init() {
		self.mode = .Noop
	}

	public var mode: LoggerMode = .Noop {
		didSet {
			switch mode {
			case .Memory:
				provider = MemoryProvider()
			case .Noop:
				provider = nil
			case .Print:
				provider = PrintLogProvider()
			}
		}
	}

	public var items: [(date: NSDate, message: String, data: [String : Any])] {
		if let provider = self.provider as? MemoryProvider {
			return provider.items
		} else {
			return []
		}
	}

	func log(message: String, data: [String : Any]) {
		provider?.log(message, data: data)
	}
}

protocol LogProvider {
	func log(message: String, data: [String : Any])
}

class MemoryProvider: LogProvider {
	private(set) var items: [(date: NSDate, message: String, data: [String : Any])]

	init() {
		items = []
	}

	func log(message: String, data: [String : Any]) {
		items.append((NSDate(), message, data))
	}
}

class PrintLogProvider: LogProvider {
	func log(message: String, data: [String : Any]) {
		print("\(NSDate()) \(message): \(data)")
	}
}
