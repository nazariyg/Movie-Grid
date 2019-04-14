// Copyright © 2019 Nazariy Gorpynyuk.
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
                switch event {
                case let .selectedMovie(movieReference, movieTitle):
                    let detailParameters = MovieDetailScene.Parameters(movieReference: movieReference, movieTitle: movieTitle)
                    UIGlobalSceneRouter.shared.go(MovieDetailScene.self, parameters: detailParameters)
                default: break
                }
            }
    }

}
