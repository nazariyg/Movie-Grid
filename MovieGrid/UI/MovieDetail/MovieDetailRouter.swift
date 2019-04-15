// Copyright © 2019 Nazariy Gorpynyuk.
// All rights reserved.

import Foundation
import Cornerstones
import Core
import ReactiveSwift
import Result

// MARK: - Protocol

protocol MovieDetailRouterProtocol {
    func wireIn(
        interactor: MovieDetailInteractorProtocol, presenter: MovieDetailPresenterProtocol, view: MovieDetailViewProtocol,
        workerQueueScheduler: QueueScheduler)
}

// MARK: - Implementation

final class MovieDetailRouter: MovieDetailRouterProtocol {

    func wireIn(
        interactor: MovieDetailInteractorProtocol, presenter: MovieDetailPresenterProtocol, view: MovieDetailViewProtocol,
        workerQueueScheduler: QueueScheduler) {}

}
