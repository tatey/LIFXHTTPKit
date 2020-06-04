//
//  Created by Tate Johnson on 13/06/2015.
//  Copyright (c) 2015 Tate Johnson. All rights reserved.
//

import Foundation

public struct Results: Decodable {
    public let results: [Result]
}

public struct Result: Decodable, Equatable, CustomStringConvertible {
	public enum Status: String, Codable {
		case OK       = "ok"
		case Async    = "async"
		case TimedOut = "timed_out"
		case Offline  = "offline"
	}
	
	public let id: String
	public let status: Status
	
	// MARK: Printable
	
	public var description: String {
		return "<Result id: \"\(id)\", status: \"\(status.rawValue)\">"
	}
}

public func ==(lhs: Result, rhs: Result) -> Bool {
	return lhs.id == rhs.id && lhs.status == rhs.status
}
