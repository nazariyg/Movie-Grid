// Copyright © 2019 Nazariy Gorpynyuk.
// All rights reserved.

import UIKit

protocol UIAnimatedInteractionController: UIViewControllerInteractiveTransitioning {

    var animationController: UIViewControllerAnimatedTransitioning? { get set }

    func canDoInteractiveTransition() -> Bool
    func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning)
    func gestureRecognizerStateChanged(withTranslation translation: CGPoint)
    func gestureRecognizerEnded()

}
