// Copyright © 2018 Nazariy Gorpynyuk.
// All rights reserved.

import Foundation

public enum CoreError: Swift.Error, CaseIterable {

    case networkingError
    case networkTimedOut

    case serverError
    case notAuthenticated
    case networkResponseNotFound
    case httpErrorCode
    case unexpectedHTTPResponseContentType
    case unexpectedHTTPResponsePayload
    case apiEntityDeserializationError

    case unknown

}
