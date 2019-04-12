// Copyright © 2019 Nazariy Gorpynyuk.
// All rights reserved.

import UIKit
import ReactiveSwift

public protocol UIScene {
    init()
    var sceneIsInitialized: Property<Bool> { get }
    var viewController: UIViewController { get }
}

public protocol ParameterizedUIScene: UIScene {
    associatedtype Parameters
    func setParameters(_ parameters: Parameters)
}

public extension UIScene {

    var workerQueueSchedulerQos: DispatchQoS {
        return .userInitiated
    }

}
