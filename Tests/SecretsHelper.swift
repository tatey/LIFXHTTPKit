//
//  Created by Tate Johnson on 21/06/2015.
//  Copyright (c) 2015 Tate Johnson. All rights reserved.
//

import Foundation

class SecretsHelper {
	private static let dictionary: NSDictionary	= {
		if let path = Bundle(for: SecretsHelper.self).path(forResource: "Secrets", ofType: "plist"), let dictionary = NSDictionary(contentsOfFile: path) {
			return dictionary
		} else {
			fatalError("Missing secrets.plist. See README.")
		}
	}()
	
	static var accessToken: String {
		return dictionary["AccessToken"] as? String ?? ""
	}
}
