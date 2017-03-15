//
//  Created by Tate Johnson on 13/06/2015.
//  Copyright (c) 2015 Tate Johnson. All rights reserved.
//

import Foundation

public let ErrorDomain: String = "LIFXHTTPKitErrorDomain"

public enum ErrorCode: Int {
	// LIFXHTTPKit Errors
	case jsonInvalid
	case unacceptableSelector
	
	// HTTP Errors
	case unexpectedHTTPStatusCode
	case unauthorized // 401
	case forbidden // 403
	case tooManyRequests // 429
	case serverError // 5XX
}

struct HTTPKitError: Error {
	let code: ErrorCode
	let message: String
	
	init(code: ErrorCode, message: String) {
		self.code = code
		self.message = message
	}
}

