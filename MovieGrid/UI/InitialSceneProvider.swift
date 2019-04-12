// Copyright © 2019 Nazariy Gorpynyuk.
// All rights reserved.

import Core

struct InitialSceneProvider {

    static func initialScene() -> UIInitialSceneType {
        return .scene(sceneType: HomeScreenScene.self)
    }

}
