// Copyright © 2019 Nazariy Gorpynyuk.
// All rights reserved.

import UIKit
import Cornerstones
import Core

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        Core.initialize()

        // App.
        App.shared.initialize(withLaunchOptions: launchOptions)

        // Global scene router.
        MovieGrid.UIGlobalSceneRouter.shared.initialize()

        return true
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // UI.
        let initialScene = InitialSceneProvider.initialScene()
        window = UI.shared.initUI(initialScene: initialScene)

        return true
    }

    // MARK: - UIApplicationDelegate events

    func applicationWillEnterForeground(_ application: UIApplication) {
        App.shared._appWillEnterForeground()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        App.shared._appDidBecomeActive()
    }

    func applicationWillResignActive(_ application: UIApplication) {
        App.shared._appWillResignActive()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        App.shared._appDidEnterBackground()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        App.shared._appWillTerminate()
    }

}
