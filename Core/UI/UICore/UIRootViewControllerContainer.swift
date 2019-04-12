// Copyright © 2019 Nazariy Gorpynyuk.
// All rights reserved.

import UIKit
import Cornerstones
import Cartography

// MARK: - Protocol

protocol UIContainerRootViewControllerProtocol {
    func setRootViewController(_ viewController: UIViewController)
    func setRootViewController(_ viewController: UIViewController, transitionStyle: UISceneTransitionStyle)
    func setRootViewController(_ viewController: UIViewController, completion: VoidClosure?)
    func setRootViewController(_ viewController: UIViewController, transitionStyle: UISceneTransitionStyle, completion: VoidClosure?)
    func containerView(forKey key: String, isUserInteractionEnabled: Bool) -> UIView
    var view: UIView! { get }
    var presentedViewController: UIViewController? { get }
}

// MARK: - Implementation

/// The parent view controller to contain any current root view controller. Allows for reducing memory footprint by replacing an existing
/// root view controller and its stack of presented/pushed view controllers with another one. Unlike dealing with UIWindow, this offers the
/// added flexibility of animated transitions and global overlay views for e.g. network status notifications and in-app notifications.
final class UIRootViewControllerContainer: UIViewController, UIContainerRootViewControllerProtocol, SharedInstance {

    typealias InstanceProtocol = UIContainerRootViewControllerProtocol
    static let defaultInstance: InstanceProtocol = UIRootViewControllerContainer()

    private var rootViewController: UIViewController?
    private var rootContainer: UIView!
    private var containerViewsContainer: UIPassthroughView!
    private var containerKeysToViews: [String: UIView] = [:]

    // MARK: - Lifecycle

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Config.shared.appearance.windowBackgroundColor

        addRootContainer()
        addContainerViewsContainer()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UI.shared._isInitialized.value = true
    }

    // MARK: - Root view controller

    private func addRootContainer() {
        rootContainer = UIView()
        view.addSubview(rootContainer)

        rootContainer.frame = view.bounds
        rootContainer.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }

    func setRootViewController(_ viewController: UIViewController) {
        setRootViewController(viewController, transitionStyle: .defaultSet)
    }

    func setRootViewController(_ viewController: UIViewController, transitionStyle: UISceneTransitionStyle) {
        setRootViewController(viewController, transitionStyle: transitionStyle, completion: nil)
    }

    func setRootViewController(_ viewController: UIViewController, completion: VoidClosure?) {
        setRootViewController(viewController, transitionStyle: .defaultSet, completion: completion)
    }

    func setRootViewController(_ viewController: UIViewController, transitionStyle: UISceneTransitionStyle, completion: VoidClosure?) {
        DispatchQueue.main.executeSync {
            loadViewIfNeeded()

            if let existingViewController = rootViewController {
                addChild(viewController)
                existingViewController.willMove(toParent: nil)
                viewController.view.frame = rootContainer.bounds
                viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                if transitionStyle != .system,
                   transitionStyle != .immediateSet,
                   let transitionAnimation = transitionStyle.transition.childViewControllerReplacementAnimation {

                    transition(
                        from: existingViewController, to: viewController,
                        duration: transitionAnimation.duration, options: transitionAnimation.options, animations: nil, completion: { [weak self] _ in
                            guard let strongSelf = self else { return }
                            existingViewController.removeFromParent()
                            viewController.didMove(toParent: strongSelf)
                            strongSelf.rootViewController = viewController
                            completion?()
                        })
                } else {
                    transition(
                        from: existingViewController, to: viewController,
                        duration: 0, options: [], animations: nil, completion: { [weak self] _ in
                            guard let strongSelf = self else { return }
                            existingViewController.removeFromParent()
                            viewController.didMove(toParent: strongSelf)
                            strongSelf.rootViewController = viewController
                            completion?()
                        })
                }
            } else {
                addChild(viewController)
                rootContainer.addSubview(viewController.view)
                viewController.didMove(toParent: self)
                viewController.view.frame = rootContainer.bounds
                viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                rootViewController = viewController
                completion?()
            }
        }
    }

    // MARK: - Container views

    private func addContainerViewsContainer() {
        containerViewsContainer = UIPassthroughView()
        view.addSubview(containerViewsContainer)

        containerViewsContainer.frame = view.bounds
        containerViewsContainer.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }

    public func containerView(forKey key: String, isUserInteractionEnabled: Bool) -> UIView {
        if let existingContainerView = containerKeysToViews[key] {
            return existingContainerView
        }

        let containerView = UIPassthroughView()
        containerView.isUserInteractionEnabled = isUserInteractionEnabled

        containerViewsContainer.addSubview(containerView)
        constrain(containerView, containerViewsContainer) { view, superview in
            view.edges == superview.edges
        }

        containerKeysToViews[key] = containerView
        return containerView
    }

    // MARK: - Event forwarding

    public override var shouldAutomaticallyForwardAppearanceMethods: Bool {
        return true
    }

    public override var childForStatusBarHidden: UIViewController? {
        return rootViewController
    }

    public override var childForStatusBarStyle: UIViewController? {
        return rootViewController
    }

    public override var childForHomeIndicatorAutoHidden: UIViewController? {
        return rootViewController
    }

    public override var childForScreenEdgesDeferringSystemGestures: UIViewController? {
        return rootViewController
    }

}
