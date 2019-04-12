// Copyright © 2018 Nazariy Gorpynyuk.
// All rights reserved.

import Foundation
import Cornerstones

public protocol BackendConfig {
    var urlScheme: URLScheme { get }
    var urlHost: String { get }
    var baseURL: URL { get }
    var apiKey: String { get }
    var serverTrustPolicyDisableEvaluationDomains: [String] { get }
}

// All environments.
public extension BackendConfig {

    var urlScheme: URLScheme {
        return .httpSecure
    }

    var serverTrustPolicyDisableEvaluationDomains: [String] { return [] }

}

// Dev environment.
public struct BackendConfigDev: BackendConfig {
    public let urlHost = "api.themoviedb.org"
    public let apiKey = "ebea8cfca72fdff8d2624ad7bbf78e4c"
}

// Prod environment.
public struct BackendConfigProd: BackendConfig {
    public let urlHost = "api.themoviedb.org"
    public let apiKey = "ebea8cfca72fdff8d2624ad7bbf78e4c"
}

public extension BackendConfig {

    var baseURL: URL {
        var urlComponents = URLComponents()
        urlComponents.scheme = urlScheme.value
        urlComponents.host = urlHost
        return urlComponents.url!
    }

}
