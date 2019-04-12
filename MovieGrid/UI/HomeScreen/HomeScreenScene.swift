// Copyright © 2019 MovieGrid.
// All rights reserved.

import Foundation
import Cornerstones
import Core
import ReactiveSwift

public struct HomeScreenScene: UIScene {

    private let _sceneIsInitialized = MutableProperty<Bool>(false)
    public let sceneIsInitialized: Property<Bool>

    private final class Components {
        var interactor: HomeScreenInteractorProtocol!
        var presenter: HomeScreenPresenterProtocol!
        var view: HomeScreenViewProtocol!
        var router: HomeScreenRouterProtocol!
    }

    private let components = Components()
    private var workerQueueScheduler: QueueScheduler!

    public init() {
        sceneIsInitialized = Property(_sceneIsInitialized)

        DispatchQueue.main.executeSync {
            let components = self.components
            let _sceneIsInitialized = self._sceneIsInitialized
            let sceneIsInitialized = self.sceneIsInitialized

            components.view = InstanceProvider.shared.instance(for: HomeScreenViewProtocol.self, defaultInstance: HomeScreenView())
            components.router = InstanceProvider.shared.instance(for: HomeScreenRouterProtocol.self, defaultInstance: HomeScreenRouter())

            let workerQueueLabel = DispatchQueue.uniqueQueueLabel()
            let workerQueueScheduler = QueueScheduler(qos: workerQueueSchedulerQos, name: workerQueueLabel)
            self.workerQueueScheduler = workerQueueScheduler

            workerQueueScheduler.schedule {
                components.interactor =
                    InstanceProvider.shared.instance(for: HomeScreenInteractorProtocol.self, defaultInstance: HomeScreenInteractor())
                components.presenter =
                    InstanceProvider.shared.instance(for: HomeScreenPresenterProtocol.self, defaultInstance: HomeScreenPresenter())

                components.interactor.wireIn(
                    sceneIsInitialized: sceneIsInitialized, presenter: components.presenter, view: components.view,
                    workerQueueScheduler: workerQueueScheduler)
                components.presenter.wireIn(
                    sceneIsInitialized: sceneIsInitialized, interactor: components.interactor, view: components.view,
                    workerQueueScheduler: workerQueueScheduler)

                DispatchQueue.main.executeSync {
                    components.view.wireIn(interactor: components.interactor, presenter: components.presenter)
                    components.router.wireIn(
                        interactor: components.interactor, presenter: components.presenter, view: components.view,
                        workerQueueScheduler: workerQueueScheduler)

                    _sceneIsInitialized.value = true
                }
            }
        }
    }

    public var viewController: UIViewController {
        return components.view as! UIViewController
    }

}
