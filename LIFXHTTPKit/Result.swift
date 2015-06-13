//
//  Created by Tate Johnson on 13/06/2015.
//  Copyright (c) 2015 Tate Johnson. All rights reserved.
//

import Foundation

public struct Result: Equatable {
	public enum Status: String {
		case OK       = "ok"
		case TimedOut = "timed_out"
		case Offline  = "offline"
	}

	public let id: String
	public let status: Status
}

public func ==(lhs: Result, rhs: Result) -> Bool {
	return lhs.id == rhs.id && lhs.status == rhs.status
}
