// Copyright © 2019 Nazariy Gorpynyuk.
// All rights reserved.

import Foundation
import Cornerstones
import Core
import ReactiveSwift
import Result
import RealmSwift

// MARK: - Protocol

protocol MovieDetailInteractorProtocol {
    func setParameters(_ parameters: MovieDetailScene.Parameters)
    func wireIn(
        sceneIsInitialized: ReactiveSwift.Property<Bool>, presenter: MovieDetailPresenterProtocol, view: MovieDetailViewProtocol,
        workerQueueScheduler: QueueScheduler)
    var requestSignal: Signal<MovieDetailInteractor.Request, NoError> { get }
}

// MARK: - Implementation

final class MovieDetailInteractor: MovieDetailInteractorProtocol, RequestEmitter {

    enum Request {
        case fillContent(movieReference: ThreadSafeReference<Movie>)
    }

    private let sceneParameters = MutableProperty<MovieDetailScene.Parameters?>(nil)

    func setParameters(_ parameters: MovieDetailScene.Parameters) {
        sceneParameters.value = parameters
    }

    func wireIn(
        sceneIsInitialized: ReactiveSwift.Property<Bool>, presenter: MovieDetailPresenterProtocol, view: MovieDetailViewProtocol,
        workerQueueScheduler: QueueScheduler) {

        sceneParameters.producer
            .skipNil()
            .startWithValues { [weak self] sceneParameters in
                self?.requestEmitter.send(value: .fillContent(movieReference: sceneParameters.movieReference))
            }
    }

}
