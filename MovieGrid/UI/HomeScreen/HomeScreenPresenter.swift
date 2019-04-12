// Copyright © 2019 MovieGrid.
// All rights reserved.

import Foundation
import Cornerstones
import Core
import ReactiveSwift
import Result
import ReactiveCocoa

// MARK: - Protocol

protocol HomeScreenPresenterProtocol {
    func wireIn(
        sceneIsInitialized: Property<Bool>, interactor: HomeScreenInteractorProtocol, view: HomeScreenViewProtocol, workerQueueScheduler: QueueScheduler)
    var requestSignal: Signal<HomeScreenPresenter.Request, NoError> { get }
    var eventSignal: Signal<HomeScreenPresenter.Event, NoError> { get }
}

// MARK: - Implementation

final class HomeScreenPresenter: HomeScreenPresenterProtocol, RequestEmitter, EventEmitter {

    enum Request {
        case someRequest
    }

    enum Event {
        case someEvent
    }

    func wireIn(
        sceneIsInitialized: Property<Bool>, interactor: HomeScreenInteractorProtocol, view: HomeScreenViewProtocol, workerQueueScheduler: QueueScheduler) {

        interactor.requestSignal
            .observe(on: workerQueueScheduler)
            .observeValues { request in
                _ = request
            }

        view.eventSignal
            .observe(on: workerQueueScheduler)
            .observeValues { event in
                _ = event
            }
    }

}
