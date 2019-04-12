// Copyright © 2019 Nazariy Gorpynyuk.
// All rights reserved.

import Foundation
import Cornerstones

// MARK: - Protocol

public protocol ErrorManagerProtocol {
    func handleError(_ error: CoreError)
}

// MARK: - Implementation

public final class ErrorManager: ErrorManagerProtocol, SharedInstance {

    public typealias InstanceProtocol = ErrorManagerProtocol
    public static let defaultInstance: InstanceProtocol = ErrorManager()

    // MARK: - Lifecycle

    private init() {}

    // MARK: - Error handling

    public func handleError(_ error: CoreError) {
        let notificationMessage = "error_generic_error_notification".localized
        log.error(notificationMessage, "")
        // Display the error to the user.
    }

}
