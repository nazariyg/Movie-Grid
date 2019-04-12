// Copyright © 2019 Nazariy Gorpynyuk.
// All rights reserved.

import UIKit

public extension UINavigationController {

    func pushViewController(_ viewController: UIViewController, animated: Bool, completion: @escaping VoidClosure) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        pushViewController(viewController, animated: animated)
        CATransaction.commit()
    }

    @discardableResult
    func popViewController(animated: Bool, completion: @escaping VoidClosure) -> UIViewController? {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        let poppedViewController = popViewController(animated: animated)
        CATransaction.commit()
        return poppedViewController
    }

    @discardableResult
    func popToViewController(_ viewController: UIViewController, animated: Bool, completion: @escaping VoidClosure) -> [UIViewController]? {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        let poppedViewControllers = popToViewController(viewController, animated: animated)
        CATransaction.commit()
        return poppedViewControllers
    }

}
