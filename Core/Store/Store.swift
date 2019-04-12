// Copyright © 2018 Nazariy Gorpynyuk.
// All rights reserved.

import Cornerstones
import RealmSwift
import ReactiveSwift

// MARK: - Protocol

public protocol StoreProtocol {
    static var main: Realm { get }
    var main: Realm { get }
    static var `default`: Realm { get }
    var `default`: Realm { get }
    func initializeMainStore(forID storeID: String)
    func forgetMainStore()
    var isMainStoreInitialized: ReactiveSwift.Property<Bool> { get }
}

// MARK: - Implementation

private let logCategory = "Store"

/// The main store is associated with a specific user and is not automatically initialized. Any globally available data is stored in the default store,
/// which is initialized automatically. When the user logs out, the main store gets "forgotten" but remains retained in case if any deferred operation
/// will need access to the store associated with the previously logged in user.
public final class Store: StoreProtocol, SharedInstance {

    public typealias InstanceProtocol = StoreProtocol
    public static let defaultInstance: InstanceProtocol = Store()

    // Skipping repeats.
    public var isMainStoreInitialized: ReactiveSwift.Property<Bool> {
        return _isMainStoreInitialized.skipRepeats()
    }
    private let _isMainStoreInitialized = MutableProperty<Bool>(false)

    private static let storeCreationDirectoryURL = FileManager.documentsURL
    private static let storeFileExtension = "realm"

    private var currentMainStoreConfiguration: Realm.Configuration?
    private var forgottenMainStoreConfiguration: Realm.Configuration?
    private let mainStoreLock = VoidObject()

    private var currentDefaultStoreConfiguration: Realm.Configuration?
    private let defaultStoreLock = VoidObject()

    // MARK: - Lifecycle

    private init() {
        // Disable Realm's "new version available" notification in the console.
        setenv("REALM_DISABLE_UPDATE_CHECKER", "1", 1)

        initializeDefaultStore()
    }

    // MARK: - Main store

    public static var main: Realm {
        return Self.shared.main
    }

    public var main: Realm {
        return synchronized(mainStoreLock) {
            if _isMainStoreInitialized.value {
                if let currentMainStoreConfiguration = currentMainStoreConfiguration,
                   let mainStore = getOrCreateMainStore(forConfiguration: currentMainStoreConfiguration) {

                    return mainStore
                }
            } else {
                // If a deferred operation is trying to access an already forgotten main store, provide that main store as a concession.
                if let forgottenMainStoreConfiguration = forgottenMainStoreConfiguration,
                   let mainStore = getOrCreateMainStore(forConfiguration: forgottenMainStoreConfiguration) {

                    return mainStore
                }
            }

            log.warning("Providing the default store instead of the main store", logCategory)
            return `default`
        }
    }

    public func initializeMainStore(forID storeID: String) {
        synchronized(mainStoreLock) {
            log.info("Initializing the main store for ID: \(storeID)", logCategory)
            guard getOrCreateQueueGlobalMainStore(forID: storeID) != nil else { return }
            forgottenMainStoreConfiguration = nil
            _isMainStoreInitialized.value = true
        }
    }

    public func forgetMainStore() {
        synchronized(mainStoreLock) {
            log.info("Forgetting the main store", logCategory)
            forgottenMainStoreConfiguration = currentMainStoreConfiguration
            currentMainStoreConfiguration = nil
            _isMainStoreInitialized.value = false
        }
    }

    // MARK: - Default store

    public static var `default`: Realm {
        return Self.shared.default
    }

    public var `default`: Realm {
        return synchronized(defaultStoreLock) {
            if let currentDefaultStoreConfiguration = currentDefaultStoreConfiguration,
               let defaultStore = getOrCreateDefaultStore(forConfiguration: currentDefaultStoreConfiguration) {

                return defaultStore
            }

            log.error("The default store is not initialized", logCategory)
            fatalError("The default store is not initialized")
        }
    }

    private func initializeDefaultStore() {
        synchronized(defaultStoreLock) {
            log.info("Initializing the default store", logCategory)
            getOrCreateQueueGlobalDefaultStore()
        }
    }

    // MARK: - Private

    private func baseStoreConfiguration() -> Realm.Configuration {
        let configuration =
            Realm.Configuration(
                schemaVersion: UInt64(StoreMigrations.currentSchemaVersion),
                migrationBlock: StoreMigrations.migrationClosure)
        return configuration
    }

    private func mainStoreConfiguration(forID storeID: String) -> Realm.Configuration {
        let storeName = storeID.isAlphanumeric ? storeID : storeID.md5
        var configuration = baseStoreConfiguration()
        let fileName = "ID-\(storeName).\(Self.storeFileExtension)"
        configuration.fileURL = Self.storeCreationDirectoryURL.appendingPathComponent(fileName)
        return configuration
    }

    private func getOrCreateQueueGlobalMainStore(forID id: String) -> Realm? {
        let configuration = mainStoreConfiguration(forID: id)

        var store: Realm?
        do {
            store = try Realm(configuration: configuration)
            currentMainStoreConfiguration = configuration
        } catch {
            log.error("Error while trying to get/create the main store: \(error)", logCategory)
            assertionFailure(error.localizedDescription)
            return nil
        }

        // Prepare accessing Realm while the device is locked.
        store?.enableBackgroundAccess()

        return store
    }

    private func getOrCreateMainStore(forConfiguration configuration: Realm.Configuration) -> Realm? {
        var store: Realm?
        do {
            store = try Realm(configuration: configuration)
        } catch {
            log.error("Error while trying to get/create the main store: \(error)", logCategory)
            assertionFailure(error.localizedDescription)
            return nil
        }

        // Prepare accessing Realm while the device is locked.
        store?.enableBackgroundAccess()

        return store
    }

    private func defaultStoreConfiguration() -> Realm.Configuration {
        var configuration = baseStoreConfiguration()
        let fileName = "Default.\(Self.storeFileExtension)"
        configuration.fileURL = Self.storeCreationDirectoryURL.appendingPathComponent(fileName)
        return configuration
    }

    @discardableResult
    private func getOrCreateQueueGlobalDefaultStore() -> Realm? {
        let configuration = defaultStoreConfiguration()

        var store: Realm?
        do {
            store = try Realm(configuration: configuration)
            currentDefaultStoreConfiguration = configuration
        } catch {
            log.error("Error while trying to get/create the default store: \(error)", logCategory)
            assertionFailure(error.localizedDescription)
            return nil
        }

        // Prepare accessing Realm while the device is locked.
        store?.enableBackgroundAccess()

        return store
    }

    private func getOrCreateDefaultStore(forConfiguration configuration: Realm.Configuration) -> Realm? {
        var store: Realm?
        do {
            store = try Realm(configuration: configuration)
        } catch {
            log.error("Error while trying to get/create the default store: \(error)", logCategory)
            assertionFailure(error.localizedDescription)
            return nil
        }

        // Prepare accessing Realm while the device is locked.
        store?.enableBackgroundAccess()

        return store
    }

    private typealias `Self` = Store

}
