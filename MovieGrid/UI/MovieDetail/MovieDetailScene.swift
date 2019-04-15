// Copyright © 2019 Nazariy Gorpynyuk.
// All rights reserved.

import Foundation
import Cornerstones
import Core
import ReactiveSwift
import RealmSwift

struct MovieDetailScene: ParameterizedUIScene {

    private let _sceneIsInitialized = MutableProperty<Bool>(false)
    let sceneIsInitialized: ReactiveSwift.Property<Bool>

    struct Parameters {
        let movieReference: ThreadSafeReference<Movie>
        let movieTitle: String?
    }

    private final class Components {
        var interactor: MovieDetailInteractorProtocol!
        var presenter: MovieDetailPresenterProtocol!
        var view: MovieDetailViewProtocol!
        var router: MovieDetailRouterProtocol!
    }

    private let components = Components()
    private var workerQueueScheduler: QueueScheduler!

    init() {
        sceneIsInitialized = Property(_sceneIsInitialized)

        DispatchQueue.main.executeSync {
            let components = self.components
            let _sceneIsInitialized = self._sceneIsInitialized
            let sceneIsInitialized = self.sceneIsInitialized

            components.view = InstanceProvider.shared.instance(for: MovieDetailViewProtocol.self, defaultInstance: MovieDetailView())
            viewController.loadViewIfNeeded()

            components.router = InstanceProvider.shared.instance(for: MovieDetailRouterProtocol.self, defaultInstance: MovieDetailRouter())

            let workerQueueLabel = DispatchQueue.uniqueQueueLabel()
            let workerQueueScheduler = QueueScheduler(qos: workerQueueSchedulerQos, name: workerQueueLabel)
            self.workerQueueScheduler = workerQueueScheduler

            workerQueueScheduler.schedule {
                components.interactor =
                    InstanceProvider.shared.instance(for: MovieDetailInteractorProtocol.self, defaultInstance: MovieDetailInteractor())
                components.presenter =
                    InstanceProvider.shared.instance(for: MovieDetailPresenterProtocol.self, defaultInstance: MovieDetailPresenter())

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

    func setParameters(_ parameters: Parameters) {
        DispatchQueue.main.executeSync {
            components.view.setParameters(parameters)
        }
        sceneIsInitialized.producer
            .filter { $0 }
            .observe(on: workerQueueScheduler)
            .startWithValues { [components] _ in
                components.interactor.setParameters(parameters)
            }
    }

    var viewController: UIViewController {
        return components.view as! UIViewController
    }

}
