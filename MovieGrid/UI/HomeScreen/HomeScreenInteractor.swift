// Copyright © 2019 MovieGrid.
// All rights reserved.

import Foundation
import Cornerstones
import Core
import ReactiveSwift
import Result

// MARK: - Protocol

protocol HomeScreenInteractorProtocol {
    func wireIn(sceneIsInitialized: Property<Bool>, presenter: HomeScreenPresenterProtocol, view: HomeScreenViewProtocol, workerQueueScheduler: QueueScheduler)
    var requestSignal: Signal<HomeScreenInteractor.Request, NoError> { get }
    var eventSignal: Signal<HomeScreenInteractor.Event, NoError> { get }
}

// MARK: - Implementation

final class HomeScreenInteractor: HomeScreenInteractorProtocol, RequestEmitter, EventEmitter {

    enum Request {
        case someRequest
    }

    enum Event {
        case someEvent
    }

    func wireIn(
        sceneIsInitialized: Property<Bool>, presenter: HomeScreenPresenterProtocol, view: HomeScreenViewProtocol, workerQueueScheduler: QueueScheduler) {

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
