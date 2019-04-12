// Copyright © 2018 Nazariy Gorpynyuk.
// All rights reserved.

import Foundation
import Cornerstones

// MARK: - Configuration

public extension Backend {
    static var baseURL: URL { return Config.shared.backend.baseURL }
    static var version: Int { return 3 }
    static var defaultRequestParameters: [String: Any] { return ["api_key": Config.shared.backend.apiKey] }
    static var imageBaseURL: URL { return Config.shared.backend.imageBaseURL }
}

// MARK: - Endpoints

public struct Backend: RemoteAPI {

    public enum API: RemoteAPIEndpoint {

        public enum Movie: RemoteAPIEndpoint {

            case nowPlaying(page: Int)

        }

    }

}
