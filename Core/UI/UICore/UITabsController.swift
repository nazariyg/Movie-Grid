// Copyright © 2019 Nazariy Gorpynyuk.
// All rights reserved.

import UIKit

public protocol UITabsControllerBase: class {}

public protocol UITabsController: UITabsControllerBase {
    init()
    var viewControllers: [UIViewController]? { get set }
    var selectedIndex: Int { get set }
}
