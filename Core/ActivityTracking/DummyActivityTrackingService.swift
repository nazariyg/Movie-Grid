// Copyright © 2019 Nazariy Gorpynyuk.
// All rights reserved.

import Foundation

public struct DummyActivityTrackingService: ActivityTrackingService {

    public func trackActivity(name: String, meta: [String: String]) {
        // Empty.
    }

    public func trackActivity(name: String) {
        trackActivity(name: name, meta: [:])
    }

}
