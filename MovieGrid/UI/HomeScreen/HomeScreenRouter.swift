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

    private var viewIsActive = true

    func wireIn(
        interactor: HomeScreenInteractorProtocol, presenter: HomeScreenPresenterProtocol, view: HomeScreenViewProtocol,
        workerQueueScheduler: QueueScheduler) {

        (view as? UIViewController)?.reactive.viewWillAppear
            .observe(on: workerQueueScheduler)
            .observeValues { [weak self] _ in
                self?.viewIsActive = true
            }

        interactor.eventSignal
            .observe(on: workerQueueScheduler)
            .observeValues { [weak self] event in
                guard let strongSelf = self else { return }
                switch event {
                case let .selectedMovie(movieReference, movieTitle):
                    guard strongSelf.viewIsActive else { break }
                    let detailParameters = MovieDetailScene.Parameters(movieReference: movieReference, movieTitle: movieTitle)
                    UIGlobalSceneRouter.shared.go(MovieDetailScene.self, parameters: detailParameters)
                    strongSelf.viewIsActive = false
                default: break
                }
            }
    }

}
