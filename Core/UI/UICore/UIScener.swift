// Copyright © 2018 Nazariy Gorpynyuk.
// All rights reserved.

import UIKit
import Cornerstones
import ReactiveSwift
import Result

// MARK: - Protocol

public protocol UIScenerProtocol {

    /// Initializes the scener with an initial scene.
    func initialize(initialSceneType: UIScene.Type)

    /// Initializes the scener with an initial scene.
    func initialize(initialSceneType: UIScene.Type, completion: VoidClosure?)

    /// Initializes the scener with a set of initial scenes supervised by a tab controller.
    func initialize(tabsControllerType: UITabsController.Type, initialSceneTypes: [UIScene.Type], initialTabIndex: Int)

    /// Initializes the scener with a set of initial scenes supervised by a tab controller.
    func initialize(tabsControllerType: UITabsController.Type, initialSceneTypes: [UIScene.Type], initialTabIndex: Int, completion: VoidClosure?)

    /// Makes a "next" transition to a scene using the default transition style for "next" transitions.
    func next<Scene: UIScene>(_: Scene.Type)

    /// Makes a "next" transition to a scene using the specified transition style.
    func next<Scene: UIScene>(_: Scene.Type, transitionStyle: UISceneTransitionStyle)

    /// Makes an "up" transition to a scene using the default transition style for "up" transitions.
    func up<Scene: UIScene>(_: Scene.Type)

    /// Makes an "up" transition to a scene using the specified transition style.
    func up<Scene: UIScene>(_: Scene.Type, transitionStyle: UISceneTransitionStyle)

    /// Makes a "set" (root view controller replacement) transition to a scene using the default transition style for "set" transitions.
    func set<Scene: UIScene>(_: Scene.Type)

    /// Makes a "set" (root view controller replacement) transition to a scene using the specified transition style.
    func set<Scene: UIScene>(_: Scene.Type, transitionStyle: UISceneTransitionStyle)

    /// Makes a "set" (root view controller replacement) transition to a scene calling back a completion afterwards.
    func set<Scene: UIScene>(_: Scene.Type, completion: VoidClosure?)

    /// Makes a "set" (root view controller replacement) transition to a scene using the specified transition style and calling back a completion afterwards.
    func set<Scene: UIScene>(_: Scene.Type, transitionStyle: UISceneTransitionStyle, completion: VoidClosure?)

    /// Makes a "next" transition to a parameterized scene using the default transition style for "next" transitions.
    func next<Scene: ParameterizedUIScene>(_: Scene.Type, parameters: Scene.Parameters)

    /// Makes a "next" transition to a parameterized scene using the specified transition style.
    func next<Scene: ParameterizedUIScene>(_: Scene.Type, parameters: Scene.Parameters, transitionStyle: UISceneTransitionStyle)

    /// Makes an "up" transition to a parameterized scene using the default transition style for "up" transitions.
    func up<Scene: ParameterizedUIScene>(_: Scene.Type, parameters: Scene.Parameters)

    /// Makes an "up" transition to a parameterized scene using the specified transition style.
    func up<Scene: ParameterizedUIScene>(_: Scene.Type, parameters: Scene.Parameters, transitionStyle: UISceneTransitionStyle)

    /// Makes a "set" (root view controller replacement) transition to a parameterized scene using the default transition style for "set" transitions.
    func set<Scene: ParameterizedUIScene>(_: Scene.Type, parameters: Scene.Parameters)

    /// Makes a "set" (root view controller replacement) transition to a parameterized scene using the specified transition style.
    func set<Scene: ParameterizedUIScene>(_: Scene.Type, parameters: Scene.Parameters, transitionStyle: UISceneTransitionStyle)

    /// Makes a "set" (root view controller replacement) transition to a tabs controller.
    func set(tabsControllerType: UITabsController.Type, initialSceneTypes: [UIScene.Type], initialTabIndex: Int)

    /// Makes a "set" (root view controller replacement) transition to a tabs controller using the specified transition style.
    func set(tabsControllerType: UITabsController.Type, initialSceneTypes: [UIScene.Type], initialTabIndex: Int, completion: @escaping VoidClosure)

    /// Makes a "set" (root view controller replacement) transition to a tabs controller using the specified transition style.
    func set(
        tabsControllerType: UITabsController.Type, initialSceneTypes: [UIScene.Type], initialTabIndex: Int, transitionStyle: UISceneTransitionStyle,
        completion: VoidClosure?)

    /// Makes a "tab" ("selectedIndex") transition to the scene currently at the top of the scene stack associated with the tab at the specified tab index.
    func tab(tabIndex: Int)

    /// Makes a "back" ("pop" or "dismiss") transition to the previous scene using the backward flavor of the transition style that was used
    /// to transition to the current scene, if any.
    func back()

    /// Makes a "back" ("pop" or "dismiss") transition with a completion closure to the previous scene using the backward flavor of the transition style
    /// that was used to transition to the current scene, if any.
    func back(completion: VoidClosure?)

    /// Traverses the scene stack back from the current scene in search for the scene of the specified type and makes a "pop" or "dismiss" transition
    /// using the backward flavor of the transition style that was used to transition to the found scene. The reverse traversal goes through
    /// any chain of "next" scenes, if such exist, and then through any chain of "up" scenes. The reverse traversal does not go beyond the last
    /// encountered scene in the first encountered chain of "up" scenes.
    func backTo<Scene: UIScene>(_: Scene.Type)

    /// Traverses the scene stack back from the current scene in search for the parameterized scene of the specified type and makes a "pop" or "dismiss"
    /// transition using the backward flavor of the transition style that was used to transition to the found scene. The reverse traversal goes through
    /// any chain of "next" scenes, if such exist, and then through any chain of "up" scenes. The reverse traversal does not go beyond the last
    /// encountered scene in the first encountered chain of "up" scenes.
    func backTo<Scene: ParameterizedUIScene>(_: Scene.Type, parameters: Scene.Parameters)

    /// Current scene.
    var currentScene: UIScene { get }

    func _popSceneIfNeeded(ifContainsViewController viewController: UIViewController)
    func _popSceneIfNeeded(ifContainsNavigationItem navigationItem: UINavigationItem)
    func _updateTabIndex(_ tabIndex: Int)

}

// MARK: - Implementation

private let logCategory = "UI"

/// Manages transitions between scenes in a stack of scenes, with support for transition styles and tabs.
/// "Next" transitions correspond to transitions when a view controller is pushed into a navigation controller and
/// "up" transitions correspond to view controller presentations. Both transitions can have their own `UISceneTransitionStyle`.
public final class UIScener: UIScenerProtocol, SharedInstance {

    public typealias InstanceProtocol = UIScenerProtocol
    public static let defaultInstance: InstanceProtocol = UIScener()

    private enum SceneNodeType {
        case root
        case next
        case up
    }

    private struct SceneNode {
        let type: SceneNodeType
        let scene: UIScene
        let uiViewController: UIViewController
        let transitionStyle: UISceneTransitionStyle?
        let cachedTransition: UISceneTransition

        init(type: SceneNodeType, scene: UIScene, uiViewController: UIViewController, transitionStyle: UISceneTransitionStyle?) {
            self.type = type
            self.scene = scene
            self.uiViewController = uiViewController
            self.transitionStyle = transitionStyle
            self.cachedTransition = transitionStyle?.transition ?? UISceneTransition()
        }
    }

    private var sceneNodeStack: [[SceneNode]] = []
    private var tabsController: UITabsController?
    private var currentTabIndex = 0
    private var currentlyActiveTransition: UISceneTransition?
    private var sceneTransitionQueue = RecursiveSerialQueue(qos: .userInteractive)

    // MARK: - Lifecycle

    private init() {}

    public func initialize(initialSceneType: UIScene.Type) {
        initialize(initialSceneType: initialSceneType, completion: nil)
    }

    public func initialize(initialSceneType: UIScene.Type, completion: VoidClosure?) {
        sceneTransitionQueue.sync {
            sceneTransitionQueue.suspend()

            DispatchQueue.main.executeSync {
                log.info("Initializing the UI with \(stringType(initialSceneType))", logCategory)

                let initialScene = initialSceneType.init()

                let rootViewController = Self.embedInNavigationControllerIfNeeded(initialScene.viewController)

                let sceneNode = SceneNode(type: .root, scene: initialScene, uiViewController: rootViewController, transitionStyle: nil)
                sceneNodeStack = [[sceneNode]]

                UIRootViewControllerContainer.shared.setRootViewController(rootViewController, completion: { [weak self] in
                    DispatchQueue.main.executeAsync {
                        completion?()
                    }
                    self?.sceneTransitionQueue.resume()
                })
            }
        }
    }

    public func initialize(tabsControllerType: UITabsController.Type, initialSceneTypes: [UIScene.Type], initialTabIndex: Int) {
        initialize(tabsControllerType: tabsControllerType, initialSceneTypes: initialSceneTypes, initialTabIndex: initialTabIndex, completion: nil)
    }

    public func initialize(tabsControllerType: UITabsController.Type, initialSceneTypes: [UIScene.Type], initialTabIndex: Int, completion: VoidClosure?) {
        sceneTransitionQueue.sync {
            sceneTransitionQueue.suspend()

            DispatchQueue.main.executeSync {
                log.info("Initializing the UI with \(stringType(tabsControllerType))", logCategory)

                let initialScenes = initialSceneTypes.map { sceneType in sceneType.init() }
                let viewControllers = initialScenes.map { scene in Self.embedInNavigationControllerIfNeeded(scene.viewController) }

                let tabsController = tabsControllerType.init()
                tabsController.viewControllers = viewControllers
                tabsController.selectedIndex = initialTabIndex
                self.tabsController = tabsController

                sceneNodeStack = initialScenes.enumerated().map { index, scene in
                    return [SceneNode(type: .root, scene: scene, uiViewController: viewControllers[index], transitionStyle: nil)]
                }
                currentTabIndex = initialTabIndex

                UIRootViewControllerContainer.shared.setRootViewController(tabsController as! UIViewController, transitionStyle: .immediateSet,
                    completion: { [weak self] in
                        DispatchQueue.main.executeAsync {
                            completion?()
                        }
                        self?.sceneTransitionQueue.resume()
                    })
            }
        }
    }

    // MARK: - Transitions

    public func next<Scene: UIScene>(_: Scene.Type) {
        next(Scene.self, transitionStyle: .defaultNext)
    }

    public func next<Scene: UIScene>(_: Scene.Type, transitionStyle: UISceneTransitionStyle) {
        next(Scene.self, transitionStyle: transitionStyle, completion: nil)
    }

    private func next<Scene: UIScene>(_: Scene.Type, transitionStyle: UISceneTransitionStyle, completion: VoidClosure?) {
        sceneTransitionQueue.async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.sceneTransitionQueue.suspend()

            DispatchQueue.main.executeAsync { [weak self] in
                guard let strongSelf = self else { return }

                guard let navigationController = strongSelf.currentSceneNode.scene.viewController.navigationController else {
                    assertionFailure()
                    return
                }

                let scene = Scene()
                let viewController = scene.viewController

                let sceneNode = SceneNode(type: .next, scene: scene, uiViewController: viewController, transitionStyle: transitionStyle)
                strongSelf.pushSceneNode(sceneNode)

                log.info("Making a \"next\" transition to \(stringType(Scene.self))", logCategory)

                strongSelf.makeNextTransition(
                    navigationController: navigationController, viewController: viewController, toScenes: [scene], transition: sceneNode.cachedTransition,
                    completion: { [weak self] in
                        DispatchQueue.main.executeAsync {
                            completion?()
                        }
                        self?.sceneTransitionQueue.resume()
                    })
            }
        }
    }

    private func makeNextTransition(
        navigationController: UINavigationController, viewController: UIViewController, toScenes: [UIScene], transition: UISceneTransition,
        completion: VoidClosure?) {

        DispatchQueue.main.executeSync {
            currentlyActiveTransition = transition
            navigationController.delegate = currentlyActiveTransition

            SignalProducer.combineLatest(toScenes.map { $0.sceneIsInitialized.producer })
                .observe(on: UIScheduler())
                .filter { $0.allSatisfy({ $0 }) }
                .startWithValues { _ in
                    navigationController.pushViewController(viewController, animated: true, completion: {
                        DispatchQueue.main.executeSync {
                            completion?()
                        }
                    })
                }
        }
    }

    public func up<Scene: UIScene>(_: Scene.Type) {
        up(Scene.self, transitionStyle: .defaultUp)
    }

    public func up<Scene: UIScene>(_: Scene.Type, transitionStyle: UISceneTransitionStyle) {
        up(Scene.self, transitionStyle: transitionStyle, completion: nil)
    }

    private func up<Scene: UIScene>(_: Scene.Type, transitionStyle: UISceneTransitionStyle, completion: VoidClosure?) {
        sceneTransitionQueue.async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.sceneTransitionQueue.suspend()

            DispatchQueue.main.executeAsync { [weak self] in
                guard let strongSelf = self else { return }

                let scene = Scene()
                let viewController = Self.embedInNavigationControllerIfNeeded(scene.viewController)

                let sceneNode = SceneNode(type: .up, scene: scene, uiViewController: viewController, transitionStyle: transitionStyle)
                let currentScene = strongSelf.currentSceneNode.scene
                strongSelf.pushSceneNode(sceneNode)

                log.info("Making an \"up\" transition to \(stringType(Scene.self))", logCategory)

                strongSelf.makeUpTransition(
                    viewController: viewController, fromScene: currentScene, toScenes: [scene], transition: sceneNode.cachedTransition,
                    completion: { [weak self] in
                        DispatchQueue.main.executeAsync {
                            completion?()
                        }
                        self?.sceneTransitionQueue.resume()
                    })
            }
        }
    }

    private func makeUpTransition(
        viewController: UIViewController, fromScene: UIScene, toScenes: [UIScene], transition: UISceneTransition, completion: VoidClosure?) {

        DispatchQueue.main.executeSync {
            currentlyActiveTransition = transition
            viewController.transitioningDelegate = currentlyActiveTransition
            if transition.presentationControllerType != nil {
                viewController.modalPresentationStyle = .custom
            }

            SignalProducer.combineLatest(toScenes.map { $0.sceneIsInitialized.producer })
                .observe(on: UIScheduler())
                .filter { $0.allSatisfy({ $0 }) }
                .startWithValues { _ in
                    fromScene.viewController.present(viewController, animated: true, completion: {
                        DispatchQueue.main.executeSync {
                            completion?()
                        }
                    })
                }
        }
    }

    public func set<Scene: UIScene>(_: Scene.Type) {
        set(Scene.self, transitionStyle: .defaultSet, completion: nil)
    }

    public func set<Scene: UIScene>(_: Scene.Type, transitionStyle: UISceneTransitionStyle) {
        set(Scene.self, transitionStyle: transitionStyle, completion: nil)
    }

    public func set<Scene: UIScene>(_: Scene.Type, completion: VoidClosure?) {
        set(Scene.self, transitionStyle: .defaultSet, completion: completion)
    }

    public func set<Scene: UIScene>(_: Scene.Type, transitionStyle: UISceneTransitionStyle, completion: VoidClosure?) {
        sceneTransitionQueue.async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.sceneTransitionQueue.suspend()

            DispatchQueue.main.executeAsync { [weak self] in
                guard let strongSelf = self else { return }

                if let presentedViewController = UIRootViewControllerContainer.shared.presentedViewController {
                    presentedViewController.dismiss(animated: false, completion: nil)
                }

                let scene = Scene()

                if !transitionStyle.isNext &&
                   !transitionStyle.isUp {

                    log.info("Setting the root scene to \(stringType(Scene.self))", logCategory)

                    let rootViewController = Self.embedInNavigationControllerIfNeeded(scene.viewController)

                    let sceneNode = SceneNode(type: .root, scene: scene, uiViewController: rootViewController, transitionStyle: nil)
                    strongSelf.sceneNodeStack = [[sceneNode]]
                    strongSelf.currentTabIndex = 0

                    scene.sceneIsInitialized.producer
                        .observe(on: UIScheduler())
                        .filter { $0 }
                        .startWithValues { _ in
                            UIRootViewControllerContainer.shared.setRootViewController(
                                rootViewController, transitionStyle: transitionStyle, completion: { [weak self] in
                                    DispatchQueue.main.executeAsync {
                                        completion?()
                                    }
                                    self?.sceneTransitionQueue.resume()
                                })
                        }

                } else {
                    let semiCompletion = { [weak self] in
                        guard let strongSelf = self else { return }
                        let transitionStyle: UISceneTransitionStyle = .immediateSet

                        let scene = Scene()

                        log.info("Setting the root scene to \(stringType(Scene.self))", logCategory)

                        let rootViewController = Self.embedInNavigationControllerIfNeeded(scene.viewController)

                        let sceneNode = SceneNode(type: .root, scene: scene, uiViewController: rootViewController, transitionStyle: nil)
                        strongSelf.sceneNodeStack = [[sceneNode]]
                        strongSelf.currentTabIndex = 0

                        scene.sceneIsInitialized.producer
                            .observe(on: UIScheduler())
                            .filter { $0 }
                            .startWithValues { _ in
                                UIRootViewControllerContainer.shared.setRootViewController(
                                    rootViewController, transitionStyle: transitionStyle, completion: { [weak self] in
                                        DispatchQueue.main.executeAsync {
                                            completion?()
                                        }
                                        self?.sceneTransitionQueue.resume()
                                    })
                            }
                    }

                    let currentScene = strongSelf.currentSceneNode.scene

                    if transitionStyle.isNext {
                        guard let navigationController = currentScene.viewController.navigationController else {
                            assertionFailure()
                            return
                        }
                        let transition = UISceneTransitionStyle.defaultNext.transition
                        strongSelf.makeNextTransition(
                            navigationController: navigationController, viewController: scene.viewController, toScenes: [scene], transition: transition,
                            completion: semiCompletion)

                    } else if transitionStyle.isUp {
                        let transition = UISceneTransitionStyle.defaultUp.transition
                        strongSelf.makeUpTransition(
                            viewController: scene.viewController, fromScene: currentScene, toScenes: [scene], transition: transition,
                            completion: semiCompletion)
                    }
                }
            }
        }
    }

    public func set(tabsControllerType: UITabsController.Type, initialSceneTypes: [UIScene.Type], initialTabIndex: Int) {
        set(tabsControllerType: tabsControllerType, initialSceneTypes: initialSceneTypes, initialTabIndex: initialTabIndex, transitionStyle: .defaultSet,
            completion: nil)
    }

    public func set(tabsControllerType: UITabsController.Type, initialSceneTypes: [UIScene.Type], initialTabIndex: Int, completion: @escaping VoidClosure) {
        set(
            tabsControllerType: tabsControllerType, initialSceneTypes: initialSceneTypes, initialTabIndex: initialTabIndex, transitionStyle: .defaultSet,
            completion: completion)
    }

    public func set(
        tabsControllerType: UITabsController.Type, initialSceneTypes: [UIScene.Type], initialTabIndex: Int, transitionStyle: UISceneTransitionStyle,
        completion: VoidClosure?) {

        sceneTransitionQueue.async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.sceneTransitionQueue.suspend()

            DispatchQueue.main.executeAsync { [weak self] in
                guard let strongSelf = self else { return }

                if let presentedViewController = UIRootViewControllerContainer.shared.presentedViewController {
                    presentedViewController.dismiss(animated: false, completion: nil)
                }

                let initialScenes = initialSceneTypes.map { sceneType in sceneType.init() }
                let viewControllers = initialScenes.map { scene in Self.embedInNavigationControllerIfNeeded(scene.viewController) }

                let tabsController = tabsControllerType.init()
                tabsController.viewControllers = viewControllers
                tabsController.selectedIndex = initialTabIndex
                let tabsControllerViewController = tabsController as! UIViewController

                if !transitionStyle.isNext &&
                   !transitionStyle.isUp {

                    log.info("Setting the root scene to \(stringType(tabsControllerType))", logCategory)

                    SignalProducer.combineLatest(initialScenes.map { $0.sceneIsInitialized.producer })
                        .observe(on: UIScheduler())
                        .filter { $0.allSatisfy({ $0 }) }
                        .startWithValues { [weak self] _ in
                            guard let strongSelf = self else { return }

                            strongSelf.sceneNodeStack = initialScenes.enumerated().map { index, scene in
                                return [SceneNode(type: .root, scene: scene, uiViewController: viewControllers[index], transitionStyle: nil)]
                            }
                            strongSelf.currentTabIndex = initialTabIndex
                            strongSelf.tabsController = tabsController

                            UIRootViewControllerContainer.shared.setRootViewController(
                                tabsControllerViewController, transitionStyle: transitionStyle,
                                completion: { [weak self] in
                                    DispatchQueue.main.executeAsync {
                                        completion?()
                                    }
                                    self?.sceneTransitionQueue.resume()
                                })
                        }
                } else {
                    let semiCompletion = {
                        let transitionStyle: UISceneTransitionStyle = .immediateSet

                        let initialScenes = initialSceneTypes.map { sceneType in sceneType.init() }
                        let viewControllers = initialScenes.map { scene in Self.embedInNavigationControllerIfNeeded(scene.viewController) }

                        let tabsController = tabsControllerType.init()
                        tabsController.viewControllers = viewControllers
                        tabsController.selectedIndex = initialTabIndex
                        let tabsControllerViewController = tabsController as! UIViewController

                        log.info("Setting the root scene to \(stringType(tabsControllerType))", logCategory)

                        SignalProducer.combineLatest(initialScenes.map { $0.sceneIsInitialized.producer })
                            .observe(on: UIScheduler())
                            .filter { $0.allSatisfy({ $0 }) }
                            .startWithValues { [weak self] _ in
                                guard let strongSelf = self else { return }

                                strongSelf.sceneNodeStack = initialScenes.enumerated().map { index, scene in
                                    return [SceneNode(type: .root, scene: scene, uiViewController: viewControllers[index], transitionStyle: nil)]
                                }
                                strongSelf.currentTabIndex = initialTabIndex
                                strongSelf.tabsController = tabsController

                                UIRootViewControllerContainer.shared.setRootViewController(
                                    tabsControllerViewController, transitionStyle: transitionStyle,
                                    completion: { [weak self] in
                                        DispatchQueue.main.executeAsync {
                                            completion?()
                                        }
                                        self?.sceneTransitionQueue.resume()
                                    })
                            }
                    }

                    let currentScene = strongSelf.currentSceneNode.scene

                    if transitionStyle.isNext {
                        guard let navigationController = currentScene.viewController.navigationController else {
                            assertionFailure()
                            return
                        }
                        let transition = UISceneTransitionStyle.defaultNext.transition
                        strongSelf.makeNextTransition(
                            navigationController: navigationController, viewController: tabsControllerViewController, toScenes: initialScenes,
                            transition: transition, completion: semiCompletion)

                    } else if transitionStyle.isUp {
                        let transition = UISceneTransitionStyle.defaultUp.transition
                        strongSelf.makeUpTransition(
                            viewController: tabsControllerViewController, fromScene: currentScene, toScenes: initialScenes,
                            transition: transition, completion: semiCompletion)
                    }
                }
            }
        }
    }

    public func next<Scene: ParameterizedUIScene>(_: Scene.Type, parameters: Scene.Parameters) {
        next(Scene.self, parameters: parameters, transitionStyle: .defaultNext)
    }

    public func next<Scene: ParameterizedUIScene>(_: Scene.Type, parameters: Scene.Parameters, transitionStyle: UISceneTransitionStyle) {
        next(Scene.self, parameters: parameters, transitionStyle: transitionStyle, completion: nil)
    }

    private func next<Scene: ParameterizedUIScene>(
        _: Scene.Type, parameters: Scene.Parameters, transitionStyle: UISceneTransitionStyle, completion: VoidClosure?) {

        sceneTransitionQueue.async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.sceneTransitionQueue.suspend()

            DispatchQueue.main.executeAsync { [weak self] in
                guard let strongSelf = self else { return }

                guard let navigationController = strongSelf.currentSceneNode.scene.viewController.navigationController else {
                    assertionFailure()
                    return
                }

                let scene = Scene()
                scene.setParameters(parameters)
                let viewController = scene.viewController

                let sceneNode = SceneNode(type: .next, scene: scene, uiViewController: viewController, transitionStyle: transitionStyle)
                strongSelf.pushSceneNode(sceneNode)

                log.info("Making a \"next\" transition to \(stringType(Scene.self))", logCategory)

                strongSelf.makeNextTransition(
                    navigationController: navigationController, viewController: viewController, toScenes: [scene], transition: sceneNode.cachedTransition,
                    completion: { [weak self] in
                        DispatchQueue.main.executeAsync {
                            completion?()
                        }
                        self?.sceneTransitionQueue.resume()
                    })
            }
        }
    }

    public func up<Scene: ParameterizedUIScene>(_: Scene.Type, parameters: Scene.Parameters) {
        up(Scene.self, parameters: parameters, transitionStyle: .defaultUp)
    }

    public func up<Scene: ParameterizedUIScene>(_: Scene.Type, parameters: Scene.Parameters, transitionStyle: UISceneTransitionStyle) {
        up(Scene.self, parameters: parameters, transitionStyle: transitionStyle, completion: nil)
    }

    private func up<Scene: ParameterizedUIScene>(
        _: Scene.Type, parameters: Scene.Parameters, transitionStyle: UISceneTransitionStyle, completion: VoidClosure?) {

        sceneTransitionQueue.async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.sceneTransitionQueue.suspend()

            DispatchQueue.main.executeAsync { [weak self] in
                guard let strongSelf = self else { return }

                let scene = Scene()
                scene.setParameters(parameters)
                let viewController = Self.embedInNavigationControllerIfNeeded(scene.viewController)

                let sceneNode = SceneNode(type: .up, scene: scene, uiViewController: viewController, transitionStyle: transitionStyle)
                let currentScene = strongSelf.currentSceneNode.scene
                strongSelf.pushSceneNode(sceneNode)

                log.info("Making an \"up\" transition to \(stringType(Scene.self))", logCategory)

                strongSelf.makeUpTransition(
                    viewController: viewController, fromScene: currentScene, toScenes: [scene], transition: sceneNode.cachedTransition,
                    completion: { [weak self] in
                        DispatchQueue.main.executeAsync {
                            completion?()
                        }
                        self?.sceneTransitionQueue.resume()
                    })
            }
        }
    }

    public func set<Scene: ParameterizedUIScene>(_: Scene.Type, parameters: Scene.Parameters) {
        set(Scene.self, parameters: parameters, transitionStyle: .defaultSet)
    }

    public func set<Scene: ParameterizedUIScene>(_: Scene.Type, parameters: Scene.Parameters, transitionStyle: UISceneTransitionStyle) {
        sceneTransitionQueue.async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.sceneTransitionQueue.suspend()

            DispatchQueue.main.executeAsync { [weak self] in
                guard let strongSelf = self else { return }

                if let presentedViewController = UIRootViewControllerContainer.shared.presentedViewController {
                    presentedViewController.dismiss(animated: false, completion: nil)
                }

                let scene = Scene()
                scene.setParameters(parameters)

                log.info("Setting the root scene to \(stringType(Scene.self))", logCategory)

                if !transitionStyle.isNext &&
                   !transitionStyle.isUp {

                    let rootViewController = Self.embedInNavigationControllerIfNeeded(scene.viewController)

                    let sceneNode = SceneNode(type: .root, scene: scene, uiViewController: rootViewController, transitionStyle: nil)
                    strongSelf.sceneNodeStack = [[sceneNode]]

                    scene.sceneIsInitialized.producer
                        .observe(on: UIScheduler())
                        .filter { $0 }
                        .startWithValues { _ in
                            UIRootViewControllerContainer.shared.setRootViewController(rootViewController, transitionStyle: transitionStyle)
                        }

                } else {
                    let semiCompletion = { [weak self] in
                        guard let strongSelf = self else { return }
                        let transitionStyle: UISceneTransitionStyle = .immediateSet

                        let scene = Scene()
                        scene.setParameters(parameters)

                        log.info("Setting the root scene to \(stringType(Scene.self))", logCategory)

                        let rootViewController = Self.embedInNavigationControllerIfNeeded(scene.viewController)

                        let sceneNode = SceneNode(type: .root, scene: scene, uiViewController: rootViewController, transitionStyle: nil)
                        strongSelf.sceneNodeStack = [[sceneNode]]

                        scene.sceneIsInitialized.producer
                            .observe(on: UIScheduler())
                            .filter { $0 }
                            .startWithValues { _ in
                                UIRootViewControllerContainer.shared.setRootViewController(rootViewController, transitionStyle: transitionStyle)
                            }
                    }

                    let currentScene = strongSelf.currentSceneNode.scene

                    if transitionStyle.isNext {
                        guard let navigationController = strongSelf.currentSceneNode.scene.viewController.navigationController else {
                            assertionFailure()
                            return
                        }
                        let transition = UISceneTransitionStyle.defaultNext.transition
                        strongSelf.makeNextTransition(
                            navigationController: navigationController, viewController: scene.viewController, toScenes: [scene], transition: transition,
                            completion: semiCompletion)

                    } else if transitionStyle.isUp {
                        let transition = UISceneTransitionStyle.defaultUp.transition
                        strongSelf.makeUpTransition(
                            viewController: scene.viewController, fromScene: currentScene, toScenes: [scene], transition: transition,
                            completion: semiCompletion)
                    }
                }
            }
        }
    }

    public func tab(tabIndex: Int) {
        DispatchQueue.main.executeSync {
            guard let tabsController = tabsController else {
                assertionFailure()
                return
            }

            guard tabIndex != tabsController.selectedIndex else { return }

            if let firstSceneNode = sceneNodeStack[currentTabIndex].first,
               let tabBarController = firstSceneNode.uiViewController.tabBarController,
               let transition = firstSceneNode.transitionStyle?.transition {

                currentlyActiveTransition = transition
                tabBarController.delegate = currentlyActiveTransition
            }

            log.info("Making a \"tab\" transition to \(stringType(sceneNodeStack[tabIndex].first!.scene))", logCategory)
            tabsController.selectedIndex = tabIndex

            currentTabIndex = tabIndex
        }
    }

    public func back() {
        back(completion: nil)
    }

    public func back(completion: VoidClosure?) {
        sceneTransitionQueue.async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.sceneTransitionQueue.suspend()

            DispatchQueue.main.executeAsync { [weak self] in
                guard let strongSelf = self else { return }

                assert(strongSelf.sceneNodeCount > 1)

                switch strongSelf.currentSceneNode.type {
                case .next:
                    guard let navigationController = strongSelf.currentSceneNode.scene.viewController.navigationController else {
                        assertionFailure()
                        return
                    }
                    if strongSelf.currentSceneNode.transitionStyle != nil {
                        let transition = strongSelf.currentSceneNode.cachedTransition
                        strongSelf.currentlyActiveTransition = transition
                        navigationController.delegate = transition
                    }
                    log.info("Making a \"back\" transition to \(stringType(strongSelf.backSceneNode.scene))", logCategory)
                    strongSelf.popSceneNode()
                    navigationController.popViewController(animated: true, completion: { [weak self] in
                        DispatchQueue.main.executeAsync {
                            completion?()
                        }
                        self?.sceneTransitionQueue.resume()
                    })
                case .up:
                    guard let presentingViewController = strongSelf.currentSceneNode.uiViewController.presentingViewController else {
                        assertionFailure()
                        return
                    }
                    if strongSelf.currentSceneNode.transitionStyle != nil {
                        let transition = strongSelf.currentSceneNode.cachedTransition
                        strongSelf.currentlyActiveTransition = transition
                        strongSelf.currentSceneNode.uiViewController.transitioningDelegate = transition
                    }
                    log.info("Making a \"back\" transition to \(stringType(strongSelf.backSceneNode.scene))", logCategory)
                    strongSelf.popSceneNode()
                    presentingViewController.dismiss(animated: true, completion: { [weak self] in
                        DispatchQueue.main.executeAsync {
                            completion?()
                        }
                        self?.sceneTransitionQueue.resume()
                    })
                default:
                    assertionFailure()
                }
            }
        }
    }

    public func backTo<Scene: UIScene>(_: Scene.Type) {
        sceneTransitionQueue.async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.sceneTransitionQueue.suspend()

            DispatchQueue.main.executeAsync { [weak self] in
                guard let strongSelf = self else { return }

                if strongSelf.currentSceneNode.scene is Scene {
                    return
                }

                let backToPresenting = { [weak self] in
                    guard let strongSelf = self else { return }
                    for index in (0..<(strongSelf.sceneNodeCount - 1)).reversed() {
                        let previousSceneNode = strongSelf.sceneNodeStack[strongSelf.currentTabIndex][index]
                        let nextSceneNode = strongSelf.sceneNodeStack[strongSelf.currentTabIndex][index + 1]
                        if previousSceneNode.scene is Scene {
                            guard let presentingViewController = nextSceneNode.uiViewController.presentingViewController else {
                                assertionFailure()
                                return
                            }
                            if strongSelf.currentSceneNode.transitionStyle != nil {
                                let transition = strongSelf.currentSceneNode.cachedTransition
                                strongSelf.currentlyActiveTransition = transition
                                strongSelf.currentSceneNode.uiViewController.transitioningDelegate = transition
                            }
                            strongSelf.sceneNodeStack[strongSelf.currentTabIndex].removeSubrange((index + 1)...)
                            log.info("Making a \"back\" transition to \(stringType(Scene.self))", logCategory)
                            presentingViewController.dismiss(animated: true, completion: { [weak self] in
                                self?.sceneTransitionQueue.resume()
                            })
                            return
                        }
                    }
                    assertionFailure()
                }

                if strongSelf.currentSceneNode.type == .next {
                    for index in (0..<(strongSelf.sceneNodeCount - 1)).reversed() {
                        let previousSceneNode = strongSelf.sceneNodeStack[strongSelf.currentTabIndex][index]
                        let nextSceneNode = strongSelf.sceneNodeStack[strongSelf.currentTabIndex][index + 1]
                        if nextSceneNode.type != .next { break }
                        if previousSceneNode.scene is Scene {
                            guard let navigationController = nextSceneNode.scene.viewController.navigationController else {
                                assertionFailure()
                                return
                            }
                            if strongSelf.currentSceneNode.transitionStyle != nil {
                                let transition = strongSelf.currentSceneNode.cachedTransition
                                strongSelf.currentlyActiveTransition = transition
                                navigationController.delegate = transition
                            }
                            strongSelf.sceneNodeStack[strongSelf.currentTabIndex].removeSubrange((index + 1)...)
                            log.info("Making a \"back\" transition to \(stringType(Scene.self))", logCategory)
                            navigationController.popToViewController(
                                previousSceneNode.scene.viewController, animated: true, completion: { [weak self] in
                                    self?.sceneTransitionQueue.resume()
                                })
                            return
                        }
                    }

                    backToPresenting()
                } else if strongSelf.currentSceneNode.type == .up {
                    backToPresenting()
                } else {
                    assertionFailure()
                }
            }
        }
    }

    public func backTo<Scene: ParameterizedUIScene>(_: Scene.Type, parameters: Scene.Parameters) {
        sceneTransitionQueue.async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.sceneTransitionQueue.suspend()

            DispatchQueue.main.executeAsync { [weak self] in
                guard let strongSelf = self else { return }

                let backToPresenting = { [weak self] in
                    guard let strongSelf = self else { return }
                    for index in (0..<(strongSelf.sceneNodeCount - 1)).reversed() {
                        let previousSceneNode = strongSelf.sceneNodeStack[strongSelf.currentTabIndex][index]
                        let nextSceneNode = strongSelf.sceneNodeStack[strongSelf.currentTabIndex][index + 1]
                        if let parameterizedScene = previousSceneNode.scene as? Scene {
                            guard let presentingViewController = nextSceneNode.uiViewController.presentingViewController else {
                                assertionFailure()
                                return
                            }
                            if strongSelf.currentSceneNode.transitionStyle != nil {
                                let transition = strongSelf.currentSceneNode.cachedTransition
                                strongSelf.currentlyActiveTransition = transition
                                strongSelf.currentSceneNode.uiViewController.transitioningDelegate = transition
                            }
                            strongSelf.sceneNodeStack[strongSelf.currentTabIndex].removeSubrange((index + 1)...)
                            log.info("Making a \"back\" transition to \(stringType(Scene.self))", logCategory)
                            presentingViewController.dismiss(animated: true, completion: { [weak self] in
                                parameterizedScene.setParameters(parameters)
                                self?.sceneTransitionQueue.resume()
                            })
                            return
                        }
                    }
                    assertionFailure()
                }

                if strongSelf.currentSceneNode.type == .next {
                    for index in (0..<(strongSelf.sceneNodeCount - 1)).reversed() {
                        let previousSceneNode = strongSelf.sceneNodeStack[strongSelf.currentTabIndex][index]
                        let nextSceneNode = strongSelf.sceneNodeStack[strongSelf.currentTabIndex][index + 1]
                        if nextSceneNode.type != .next { break }
                        if let parameterizedScene = previousSceneNode.scene as? Scene {
                            guard let navigationController = nextSceneNode.scene.viewController.navigationController else {
                                assertionFailure()
                                return
                            }
                            if strongSelf.currentSceneNode.transitionStyle != nil {
                                let transition = strongSelf.currentSceneNode.cachedTransition
                                strongSelf.currentlyActiveTransition = transition
                                navigationController.delegate = transition
                            }
                            strongSelf.sceneNodeStack[strongSelf.currentTabIndex].removeSubrange((index + 1)...)
                            log.info("Making a \"back\" transition to \(stringType(Scene.self))", logCategory)
                            navigationController.popToViewController(
                                parameterizedScene.viewController, animated: true,
                                completion: { [weak self] in
                                    parameterizedScene.setParameters(parameters)
                                    self?.sceneTransitionQueue.resume()
                                })
                            return
                        }
                    }

                    backToPresenting()
                } else if strongSelf.currentSceneNode.type == .up {
                    backToPresenting()
                } else {
                    assertionFailure()
                }
            }
        }
    }

    public var currentScene: UIScene {
        return DispatchQueue.main.executeSync {
            return currentSceneNode.scene
        }
    }

    public func _popSceneIfNeeded(ifContainsViewController viewController: UIViewController) {
        DispatchQueue.main.executeSync {
            let doPop: Bool
            let currentViewController = currentSceneNode.uiViewController
            if viewController === currentViewController {
                doPop = true
            } else {
                doPop = currentViewController.children.contains { childViewController -> Bool in
                    return viewController === childViewController
                }
            }

            if doPop {
                popSceneNode()
            }
        }
    }

    public func _popSceneIfNeeded(ifContainsNavigationItem navigationItem: UINavigationItem) {
        DispatchQueue.main.executeSync {
            let currentViewController = currentSceneNode.uiViewController
            if currentViewController.navigationItem === navigationItem {
                popSceneNode()
            }
        }
    }

    public func _updateTabIndex(_ tabIndex: Int) {
        DispatchQueue.main.executeSync {
            currentTabIndex = tabIndex
        }
    }

    // MARK: - Private

    private static func embedInNavigationControllerIfNeeded(_ viewController: UIViewController) -> UIViewController {
        if !(viewController is UINavigationController) &&
           !(viewController is UITabBarController) &&
           !(viewController is UISplitViewController) {

            // Embed into a UINavigationController.
            return UIEmbeddingNavigationController(rootViewController: viewController)
        } else {
            // Use as is.
            return viewController
        }
    }

    private var currentSceneNode: SceneNode {
        return sceneNodeStack[currentTabIndex].last!
    }

    private var underlyingSceneNode: SceneNode? {
        return sceneNodeStack[currentTabIndex][safe: sceneNodeStack[currentTabIndex].lastIndex - 1]
    }

    private func pushSceneNode(_ sceneNode: SceneNode) {
        return sceneNodeStack[currentTabIndex].append(sceneNode)
    }

    private func popSceneNode() {
        sceneNodeStack[currentTabIndex].removeLast()
    }

    private var sceneNodeCount: Int {
        return sceneNodeStack[currentTabIndex].count
    }

    private var backSceneNode: SceneNode {
        let lastIndex = sceneNodeStack[currentTabIndex].lastIndex
        return sceneNodeStack[currentTabIndex][lastIndex - 1]
    }

    private typealias `Self` = UIScener

}
