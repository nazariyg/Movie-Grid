// Copyright © 2018 Nazariy Gorpynyuk.
// All rights reserved.

import UIKit

public struct UnpackedViewControllerContextTransitioning {

    public let containerView: UIView
    public let fromVC: UIViewController
    public let toVC: UIViewController
    public let fromView: UIView
    public let toView: UIView
    public let fromViewStartFrame: CGRect
    public let toViewEndFrame: CGRect

}

public extension UIViewControllerContextTransitioning {

    func unpack() -> UnpackedViewControllerContextTransitioning {
        let containerView = self.containerView
        let fromVC = viewController(forKey: .from)!
        let toVC = viewController(forKey: .to)!
        let fromView = view(forKey: .from) ?? fromVC.view!.snapshotView(afterScreenUpdates: false)!
        let toView = view(forKey: .to) ?? toVC.view!.snapshotView(afterScreenUpdates: false)!
        let fromViewStartFrame = initialFrame(for: fromVC)
        let toViewEndFrame = finalFrame(for: toVC)

        let unpackedContext =
            UnpackedViewControllerContextTransitioning(
                containerView: containerView,
                fromVC: fromVC,
                toVC: toVC,
                fromView: fromView,
                toView: toView,
                fromViewStartFrame: fromViewStartFrame,
                toViewEndFrame: toViewEndFrame)
        return unpackedContext
    }

}
