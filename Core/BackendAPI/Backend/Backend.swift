// Copyright © 2018 Nazariy Gorpynyuk.
// All rights reserved.

import Foundation
import Cornerstones

// MARK: - Configuration

public extension Backend {
    static var baseURL: URL { return Config.shared.backend.baseURL }
    static var version: Int { return 3 }
    static var defaultRequestParameters: [String: Any] { return ["api_key": Config.shared.backend.apiKey] }
}

public extension RemoteAPIEndpoint {

    static var backendType: RemoteAPI.Type { return Backend.self }
    static var rootEndpointType: RemoteAPIEndpoint.Type { return Backend.API.Movie.self }

    func requestParameters(for parameters: [String: Any]) -> HTTPRequestParameters {
        return HTTPRequestParameters(
            Self.backendType.defaultRequestParameters
            .mergingWithReplacing(dictionary: parameters))
    }

}

// MARK: - Endpoints

public struct Backend: RemoteAPI {

    public enum API: RemoteAPIEndpoint {

        public enum Movie: RemoteAPIEndpoint {

            case nowPlaying(page: Int)

        }

    }

    public struct ParameterKey {
        public static let page = "page"
    }

}
