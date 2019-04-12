// Copyright © 2019 Nazariy Gorpynyuk.
// All rights reserved.

import Foundation
import Cornerstones

public extension RemoteAPIEndpoint {

    static var backendType: RemoteAPI.Type { return Backend.self }
    static var rootEndpointType: RemoteAPIEndpoint.Type { return Backend.API.Movie.self }

    func requestParameters(for parameters: [String: Any]) -> HTTPRequestParameters {
        return HTTPRequestParameters(
            Self.backendType.defaultRequestParameters
            .mergingWithReplacing(dictionary: parameters))
    }

}
