// Copyright © 2019 MovieGrid.
// All rights reserved.

import Foundation
import Cornerstones
import Core
import ReactiveSwift
import Result

// MARK: - Protocol

protocol HomeScreenRouterProtocol {
    func wireIn(
        interactor: HomeScreenInteractorProtocol, presenter: HomeScreenPresenterProtocol, view: HomeScreenViewProtocol,
        workerQueueScheduler: QueueScheduler)
}

// MARK: - Implementation

final class HomeScreenRouter: HomeScreenRouterProtocol {

    func wireIn(
        interactor: HomeScreenInteractorProtocol, presenter: HomeScreenPresenterProtocol, view: HomeScreenViewProtocol,
        workerQueueScheduler: QueueScheduler) {

        interactor.eventSignal
            .observe(on: workerQueueScheduler)
            .observeValues { event in
                _ = event
            }

        presenter.eventSignal
            .observe(on: workerQueueScheduler)
            .observeValues { event in
                _ = event
            }

        view.eventSignal
            .observe(on: workerQueueScheduler)
            .observeValues { event in
                _ = event
            }
    }

}
