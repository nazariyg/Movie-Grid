// Copyright © 2019 Nazariy Gorpynyuk.
// All rights reserved.

import UIKit

public final class UISceneTransition: NSObject {

    struct ChildViewControllerReplacementAnimation {
        let duration: TimeInterval
        let options: UIView.AnimationOptions
    }

    private(set) var animationControllerForPresentation: UIViewControllerAnimatedTransitioning?
    private(set) var animationControllerForDismissal: UIViewControllerAnimatedTransitioning?
    private(set) var presentationControllerType: UIInteractablePresentationController.Type?
    private(set) var interactionControllerForPresentation: UIAnimatedInteractionController?
    private(set) var interactionControllerForDismissal: UIAnimatedInteractionController?
    private(set) var childViewControllerReplacementAnimation: ChildViewControllerReplacementAnimation?

    private(set) var presentationController: UIInteractablePresentationController?

    override init() {
        super.init()
    }

    init(animationController: UIViewControllerAnimatedTransitioning) {
        self.animationControllerForPresentation = animationController
    }

    init(presentationControllerType: UIInteractablePresentationController.Type) {
        self.presentationControllerType = presentationControllerType
    }

    init(
        animationControllerForPresentation: UIViewControllerAnimatedTransitioning,
        animationControllerForDismissal: UIViewControllerAnimatedTransitioning) {

        self.animationControllerForPresentation = animationControllerForPresentation
        self.animationControllerForDismissal = animationControllerForDismissal
    }

    init(
        animationControllerForPresentation: UIViewControllerAnimatedTransitioning,
        animationControllerForDismissal: UIViewControllerAnimatedTransitioning,
        presentationControllerType: UIInteractablePresentationController.Type) {

        self.animationControllerForPresentation = animationControllerForPresentation
        self.animationControllerForDismissal = animationControllerForDismissal
        self.presentationControllerType = presentationControllerType
    }

    init(
        animationControllerForPresentation: UIViewControllerAnimatedTransitioning,
        animationControllerForDismissal: UIViewControllerAnimatedTransitioning,
        interactionControllerForPresentation: UIAnimatedInteractionController,
        interactionControllerForDismissal: UIAnimatedInteractionController) {

        self.animationControllerForPresentation = animationControllerForPresentation
        self.animationControllerForDismissal = animationControllerForDismissal
        self.interactionControllerForPresentation = interactionControllerForPresentation
        self.interactionControllerForDismissal = interactionControllerForDismissal
    }

    init(
        animationControllerForPresentation: UIViewControllerAnimatedTransitioning,
        animationControllerForDismissal: UIViewControllerAnimatedTransitioning,
        presentationControllerType: UIInteractablePresentationController.Type,
        interactionControllerForDismissal: UIAnimatedInteractionController) {

        self.animationControllerForPresentation = animationControllerForPresentation
        self.animationControllerForDismissal = animationControllerForDismissal
        self.presentationControllerType = presentationControllerType
        self.interactionControllerForDismissal = interactionControllerForDismissal
    }

    init(
        animationControllerForPresentation: UIViewControllerAnimatedTransitioning,
        animationControllerForDismissal: UIViewControllerAnimatedTransitioning,
        presentationControllerType: UIInteractablePresentationController.Type,
        interactionControllerForPresentation: UIAnimatedInteractionController,
        interactionControllerForDismissal: UIAnimatedInteractionController) {

        self.animationControllerForPresentation = animationControllerForPresentation
        self.animationControllerForDismissal = animationControllerForDismissal
        self.presentationControllerType = presentationControllerType
        self.interactionControllerForPresentation = interactionControllerForPresentation
        self.interactionControllerForDismissal = interactionControllerForDismissal
    }

    init(childViewControllerReplacementAnimation: ChildViewControllerReplacementAnimation) {
        self.childViewControllerReplacementAnimation = childViewControllerReplacementAnimation
    }

}

extension UISceneTransition: UIViewControllerTransitioningDelegate {

    public func animationController(
        forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {

        return animationControllerForPresentation
    }

    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return animationControllerForDismissal
    }

    public func presentationController(
        forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {

        if let presentationController = self.presentationController {
            return presentationController
        }

        guard let presentationControllerType = presentationControllerType else { return nil }
        let presentationController = presentationControllerType.init(presentedViewController: presented, presenting: presenting)
        self.presentationController = presentationController
        return presentationController
    }

    public func interactionControllerForPresentation(
        using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {

        return interactionControllerForPresentation
    }

    public func interactionControllerForDismissal(
        using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {

        if let presentationController = presentationController, presentationController.isInteracting {
            interactionControllerForDismissal?.animationController = animator
            presentationController.animatedInteractionController = interactionControllerForDismissal
            return interactionControllerForDismissal
        } else {
            return nil
        }
    }

}

extension UISceneTransition: UINavigationControllerDelegate {

    public func navigationController(
        _ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation,
        from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {

        switch operation {
        case .push: return animationControllerForPresentation
        case .pop: return animationControllerForDismissal
        default: return nil
        }
    }

    public func navigationController(
        _ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning)
        -> UIViewControllerInteractiveTransitioning? {

        return interactionControllerForPresentation
    }

}

extension UISceneTransition: UITabBarControllerDelegate {

    public func tabBarController(
        _ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController)
        -> UIViewControllerAnimatedTransitioning? {

        return animationControllerForPresentation
    }

    public func tabBarController(
        _ tabBarController: UITabBarController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning)
        -> UIViewControllerInteractiveTransitioning? {

        return interactionControllerForPresentation
    }

}
