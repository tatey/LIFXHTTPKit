//
//  Created by Tate Johnson on 12/07/2015.
//  Copyright (c) 2015 Tate Johnson. All rights reserved.
//

import Foundation
import LIFXHTTPKit

class ClientHelper {
	static let sharedClient: Client = {
		println("default")
		let client = Client(accessToken: SecretsHelper.accessToken)
		let semaphore = dispatch_semaphore_create(0)
		client.fetch { (error) in
			if error != nil {
				fatalError("\(__FUNCTION__): Shared client failed to initialize. Are you using a genuine access token? See README.")
			}
			dispatch_semaphore_signal(semaphore)
		}
		dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
		return client
	}()
}
