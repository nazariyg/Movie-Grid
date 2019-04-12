// Copyright © 2018 Nazariy Gorpynyuk.
// All rights reserved.

import Foundation

// MARK: - Protocol

public protocol RemoteAPI {
    static var baseURL: URL { get }
    static var url: RemoteAPIURLSubscript { get }
}

// MARK: - Implementation

public extension RemoteAPI {

    static var url: RemoteAPIURLSubscript {
        return RemoteAPIURLSubscript(apiType: self)
    }

}

public final class RemoteAPIURLSubscript {

    private let apiType: RemoteAPI.Type

    fileprivate init(apiType: RemoteAPI.Type) {
        self.apiType = apiType
    }

    public subscript(endpoint: RemoteAPIEndpoint) -> URL {
        let endpointPath = endpoint.path
        let url = apiType.baseURL.appendingPathComponent(endpointPath)
        return url
    }

}
