// Copyright © 2018 Nazariy Gorpynyuk.
// All rights reserved.

import Foundation
import Cornerstones
import Alamofire
import ReactiveSwift
import Result

public typealias NetworkStatus = NetworkReachabilityManager.NetworkReachabilityStatus
public typealias NetworkConnectionType = NetworkReachabilityManager.ConnectionType

// MARK: - Protocol

public protocol NetworkProtocol {
    var isOnline: Property<Bool?> { get }
    var eventSignal: Signal<Network.Event, NoError> { get }  // NetworkEventEmitterProtocol
}

// MARK: - Implementation

private let logCategory = "Network"

public final class Network: NetworkProtocol, EventEmitter, SharedInstance {

    public enum Event: Equatable {
        case isOnline(connectionType: NetworkConnectionType)
        case isOffline
    }

    public typealias InstanceProtocol = NetworkProtocol
    public static let defaultInstance: InstanceProtocol = Network()

    /// Skipping repeats.
    public var isOnline: Property<Bool?> {
        return _isOnline.skipRepeats()
    }
    private let _isOnline = MutableProperty<Bool?>(nil)

    private var reachabilityManager: NetworkReachabilityManager?

    // MARK: - Lifecycle

    private init() {
        log.debug("Initializing the network", logCategory)

        if let reachabilityManager = NetworkReachabilityManager() {
            _isOnline.value = reachabilityManager.isReachable
        }

        startListeningOnReachability()
    }

    // MARK: - Network status

    private func startListeningOnReachability() {
        if let reachabilityManager = NetworkReachabilityManager() {
            self.reachabilityManager = reachabilityManager
            reachabilityManager.listener = { [weak self] status in
                self?.reachabilityStatusDidChange(toStatus: status)
            }
            reachabilityManager.startListening()
        } else {
            log.error("Could not instantiate a reachability manager", logCategory)
        }
    }

    private func reachabilityStatusDidChange(toStatus status: NetworkStatus) {
        switch status {
        case .reachable(let connectionType):
            log.info("Online. Connected over \(connectionType).", logCategory)
            _isOnline.value = true
            eventEmitter.send(value: .isOnline(connectionType: connectionType))
        case .notReachable:
            log.info("Offline", logCategory)
            _isOnline.value = false
            eventEmitter.send(value: .isOffline)
        case .unknown:
            log.warning("Internet reachability status is unknown", logCategory)
        }
    }

}

extension NetworkReachabilityManager.ConnectionType: CustomStringConvertible {

    public var description: String {
        switch self {
        case .ethernetOrWiFi:
            return "WiFi"
        case .wwan:
            return "WWAN"
        }
    }

}
