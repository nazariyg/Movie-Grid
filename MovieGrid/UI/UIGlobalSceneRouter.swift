// Copyright © 2019 Nazariy Gorpynyuk.
// All rights reserved.

import Cornerstones
import Core
import UIKit
import ReactiveSwift

public final class UIGlobalSceneRouter: UIGlobalSceneRouterProtocol {

    public static let shared = UIGlobalSceneRouter()

    // MARK: - Lifecycle

    private init() {}

    public func initialize() {
        DispatchQueue.main.executeSync {
            Core.UIGlobalSceneRouter.defaultInstance = self
        }
    }

    // MARK: - Routing

    public func go<Scene: UIScene>(_ toSceneType: Scene.Type) {
        DispatchQueue.main.executeSync {

            //

        }
    }

    public func go<Scene: ParameterizedUIScene>(_ toSceneType: Scene.Type, parameters: Scene.Parameters) {
        DispatchQueue.main.executeSync {

            //

        }
    }

    public func goBack() {
        DispatchQueue.main.executeSync {
            UIScener.shared.back()
        }
    }

    public func goBack(completion: @escaping VoidClosure) {
        DispatchQueue.main.executeSync {
            UIScener.shared.back(completion: completion)
        }
    }

    private typealias `Self` = UIGlobalSceneRouter

}
