// Copyright © 2018 Nazariy Gorpynyuk.
// All rights reserved.

import UIKit
import Cornerstones
import ReactiveSwift
import Result

// MARK: - Protocol

public protocol AppProtocol {
    func initialize(withLaunchOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?)
    var isInForeground: Property<Bool> { get }
    var version: String { get }
    var buildNumber: String { get }
    var fullVersion: String { get }
    func openSystemSettings()
    var eventSignal: Signal<App.Event, NoError> { get }  // AppEventEmitterProtocol

    // For AppDelegate.
    func _appWillEnterForeground()
    func _appDidBecomeActive()
    func _appWillResignActive()
    func _appDidEnterBackground()
    func _appWillTerminate()
}

// MARK: - Implementation

private let logCategory = "App"

public final class App: AppProtocol, EventEmitter, SharedInstance {

    public enum Event {
        case willEnterForeground
        case didBecomeActive
        case willResignActive
        case didEnterBackground
        case willTerminate
    }

    public typealias InstanceProtocol = AppProtocol
    public static let defaultInstance: InstanceProtocol = App()

    private var launchOptions: [UIApplication.LaunchOptionsKey: Any]?

    /// Skipping repeats.
    public var isInForeground: Property<Bool> {
        return _isInForeground.skipRepeats()
    }
    private let _isInForeground = MutableProperty<Bool>(false)

    // MARK: - Lifecycle

    private init() {}

    // Called by AppDelegate.
    public func initialize(withLaunchOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        DispatchQueue.main.executeSync {
            log.debug("Initializing the app", logCategory)

            self.launchOptions = launchOptions

            log.appInfo()
            if let launchOptions = launchOptions {
                log.infoInvocation()
                log.info("launchOptions: \(launchOptions)", logCategory)
            }
        }
    }

    // MARK: - App info

    public var version: String {
        return DispatchQueue.main.executeSync {
            let infoDictionary = Bundle.main.infoDictionary
            let version = infoDictionary?["CFBundleShortVersionString"] as? String
            return version ?? ""
        }
    }

    public var buildNumber: String {
        return DispatchQueue.main.executeSync {
            let infoDictionary = Bundle.main.infoDictionary
            let buildNumber = infoDictionary?["CFBundleVersion"] as? String
            return buildNumber ?? ""
        }
    }

    public var fullVersion: String {
        return DispatchQueue.main.executeSync {
            let fullVersion = "\(version) (\(buildNumber))"
            return fullVersion
        }
    }

    // MARK: - System settings

    public func openSystemSettings() {
        DispatchQueue.main.executeAsync {
            let app = UIApplication.shared
            let settingsURL = URL(string: UIApplication.openSettingsURLString)!
            if app.canOpenURL(settingsURL) {
                app.open(settingsURL)
            }
        }
    }

    // MARK: - UIApplicationDelegate events to be called by the AppDelegate only

    public func _appWillEnterForeground() {
        DispatchQueue.main.executeSync {
            log.info("App will enter foreground", logCategory)
            eventEmitter.send(value: .willEnterForeground)
        }
    }

    public func _appDidBecomeActive() {
        DispatchQueue.main.executeSync {
            log.info("App did become active", logCategory)
            _isInForeground.value = true
            eventEmitter.send(value: .didBecomeActive)
        }
    }

    public func _appWillResignActive() {
        DispatchQueue.main.executeSync {
            log.info("App will resign active", logCategory)
            eventEmitter.send(value: .willResignActive)
        }
    }

    public func _appDidEnterBackground() {
        DispatchQueue.main.executeSync {
            log.info("App did enter background", logCategory)
            _isInForeground.value = false
            eventEmitter.send(value: .didEnterBackground)
        }
    }

    public func _appWillTerminate() {
        DispatchQueue.main.executeSync {
            log.info("App will terminate", logCategory)
            eventEmitter.send(value: .willTerminate)
        }
    }

}
