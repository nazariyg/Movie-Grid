// Copyright © 2019 Nazariy Gorpynyuk.
// All rights reserved.

import UIKit
import Cornerstones

class UIInteractablePresentationController: UIPresentationController {

    var interactiveDismissalEnabled: Bool {
        return true
    }

    private(set) var isInteracting = false
    weak var animatedInteractionController: UIAnimatedInteractionController?

    required override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
    }

    override func presentationTransitionDidEnd(_ completed: Bool) {
        super.presentationTransitionDidEnd(completed)

        guard
            interactiveDismissalEnabled,
            completed,
            let presentedView = presentedView
        else { return }

        let panGestureRecognizer = UIPanGestureRecognizer()
        panGestureRecognizer.reactive.stateChanged
            .observeValues { [weak self] gestureRecognizer in
                guard let strongSelf = self else { return }

                // Cancel touches while animating.
                if let animatedInteractionController = strongSelf.animatedInteractionController {
                    if !animatedInteractionController.canDoInteractiveTransition() {
                        gestureRecognizer.isEnabled = false
                        gestureRecognizer.isEnabled = true
                        return
                    }
                }

                switch gestureRecognizer.state {

                case .began:
                    strongSelf.isInteracting = true
                    strongSelf.presentingViewController.dismiss(animated: true, completion: nil)

                case .changed:
                    guard
                        let view = gestureRecognizer.view,
                        let animatedInteractionController = strongSelf.animatedInteractionController
                    else { break }

                    let translation = gestureRecognizer.translation(in: view)
                    animatedInteractionController.gestureRecognizerStateChanged(withTranslation: translation)

                case .ended, .cancelled:
                    strongSelf.isInteracting = false

                    guard let animatedInteractionController = strongSelf.animatedInteractionController else { break }
                    animatedInteractionController.gestureRecognizerEnded()

                default: break
                }
            }
        presentedView.addGestureRecognizer(panGestureRecognizer)
    }

}
