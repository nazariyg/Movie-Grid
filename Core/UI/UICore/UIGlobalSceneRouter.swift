// Copyright © 2019 Nazariy Gorpynyuk.
// All rights reserved.

import Foundation
import Cornerstones
import UIKit

public protocol UIGlobalSceneRouterProtocol {

    func go<Scene: UIScene>(_ toSceneType: Scene.Type)
    func go<Scene: ParameterizedUIScene>(_ toSceneType: Scene.Type, parameters: Scene.Parameters)
    func goBack()
    func goBack(completion: @escaping VoidClosure)

}

public final class UIGlobalSceneRouter: SharedInstance {

    public typealias InstanceProtocol = UIGlobalSceneRouterProtocol
    public static var defaultInstance: InstanceProtocol = DummyUIGlobalSceneRouter()

}

private final class DummyUIGlobalSceneRouter: UIGlobalSceneRouterProtocol {
    func go<Scene: UIScene>(_ toSceneType: Scene.Type) {}
    func go<Scene: ParameterizedUIScene>(_ toSceneType: Scene.Type, parameters: Scene.Parameters) {}
    func goBack() {}
    func goBack(completion: @escaping VoidClosure) {}
}
