// Copyright © 2019 Nazariy Gorpynyuk.
// All rights reserved.

import UIKit

public enum UIInitialSceneType {
    case scene(sceneType: UIScene.Type)
    case tabs(tabsControllerType: UITabsController.Type, tabSceneTypes: [UIScene.Type], initialTabIndex: Int)
}
