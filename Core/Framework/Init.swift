// Copyright © 2019 Nazariy Gorpynyuk.
// All rights reserved.

import Foundation

public func initialize() {
    DispatchQueue.main.executeSync {
        _ = Store.shared
        _ = Network.shared
        _ = UINetworkStatusNotifier.shared
    }
}
