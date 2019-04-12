// Copyright © 2019 Nazariy Gorpynyuk.
// All rights reserved.

import UIKit
import Cornerstones
import ReactiveSwift

// MARK: - Protocol

public protocol UIProtocol {

    var isInitialized: Property<Bool> { get }
    func initUI(initialScene: UIInitialSceneType) -> UIWindow

    var _isInitialized: MutableProperty<Bool> { get }

}

// MARK: - Implementation

public final class UI: UIProtocol, SharedInstance {

    public typealias InstanceProtocol = UIProtocol
    public static var defaultInstance: UIProtocol = UI()

    /// Skipping repeats.
    public var isInitialized: Property<Bool> {
        return _isInitialized.skipRepeats()
    }
    public let _isInitialized = MutableProperty<Bool>(false)

    // MARK: - Lifecycle

    private init() {}

    // MARK: - UI

    public func initUI(initialScene: UIInitialSceneType) -> UIWindow {
        return DispatchQueue.main.executeSync {
            let screenSize = UIScreen.main.bounds.size
            let window = UIWindow(frame: CGRect(origin: .zero, size: screenSize))

            window.rootViewController = UIRootViewControllerContainer.shared as? UIViewController

            let backgroundColor = Config.shared.appearance.windowBackgroundColor
            window.backgroundColor = backgroundColor
            UIRootViewControllerContainer.shared.view.backgroundColor = backgroundColor

            window.makeKeyAndVisible()

            switch initialScene {
            case let .scene(sceneType):
                UIScener.shared.initialize(initialSceneType: sceneType)
            case let .tabs(tabsControllerType, tabSceneTypes, initialTabIndex):
                UIScener.shared.initialize(
                    tabsControllerType: tabsControllerType, initialSceneTypes: tabSceneTypes,
                    initialTabIndex: initialTabIndex)
            }

            return window
        }
    }

}
