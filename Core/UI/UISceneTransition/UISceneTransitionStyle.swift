// Copyright © 2019 Nazariy Gorpynyuk.
// All rights reserved.

import UIKit

public enum UISceneTransitionStyle {

    case system
    case defaultNext
    case defaultUp
    case defaultSet
    case immediateSet

    public var transition: UISceneTransition {
        switch self {

        case .system:
            let transition = UISceneTransition()
            return transition

        case .defaultNext:
            let transition =
                UISceneTransition(
                    animationControllerForPresentation: UIShiftyZoomyAnimationController(isReversed: false),
                    animationControllerForDismissal: UIShiftyZoomyAnimationController(isReversed: true))
            return transition

        case .defaultUp:
            let transition =
                UISceneTransition(
                    animationControllerForPresentation: UISlidyZoomyAnimationController(isReversed: false),
                    animationControllerForDismissal: UISlidyZoomyAnimationController(isReversed: true))
            return transition

        case .defaultSet:
            let animation =
                UISceneTransition.ChildViewControllerReplacementAnimation(
                    duration: 0.33, options: .transitionCrossDissolve)
            let transition = UISceneTransition(childViewControllerReplacementAnimation: animation)
            return transition

        case .immediateSet:
            let transition = UISceneTransition()
            return transition

        }

    }

    public var isNext: Bool {
        switch self {
        case .defaultNext:
            return true
        default:
            return false
        }
    }

    public var isUp: Bool {
        switch self {
        case .defaultUp:
            return true
        default:
            return false
        }
    }

}
