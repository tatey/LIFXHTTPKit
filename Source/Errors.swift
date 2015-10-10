//
//  Created by Tate Johnson on 13/06/2015.
//  Copyright (c) 2015 Tate Johnson. All rights reserved.
//

import Foundation

public let ErrorDomain: String = "LIFXHTTPKitErrorDomain"

public enum ErrorCode: Int {
	case JSONInvalid
	case UnacceptableSelector
	case UnexpectedResponseStatusCode
}
