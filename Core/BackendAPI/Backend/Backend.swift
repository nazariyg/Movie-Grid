// Copyright © 2018 Nazariy Gorpynyuk.
// All rights reserved.

import Foundation
import Cornerstones

// MARK: - Configuration

public extension Backend {
    static var baseURL: URL { return Config.shared.backend.baseURL }
}

public extension RemoteAPIEndpoint {
    static var backendType: RemoteAPI.Type { return Backend.self }
    static var rootEndpointType: RemoteAPIEndpoint.Type { return Backend.API.self }
}

// MARK: - Endpoints

public struct Backend: RemoteAPI {

    // API
    public enum API: RemoteAPIEndpoint {

        //

    }

}
