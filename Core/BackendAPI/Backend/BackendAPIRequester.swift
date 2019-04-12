// Copyright © 2019 Nazariy Gorpynyuk.
// All rights reserved.

import Foundation
import Cornerstones
import ReactiveSwift

public struct BackendAPIRequester {

    public static func making(_ request: HTTPRequest) -> SignalProducer<HTTPDataResponse, CoreError> {
        // Use a stateless session manager.
        let sessionManager = Requester.shared.stateless

        return sessionManager.making(request: request, for: Data.self)
    }

}
