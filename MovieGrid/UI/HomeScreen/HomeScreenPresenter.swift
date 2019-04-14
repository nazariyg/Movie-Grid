// Copyright © 2019 Nazariy Gorpynyuk.
// All rights reserved.

import Foundation
import Cornerstones
import Core
import ReactiveSwift
import Result
import ReactiveCocoa
import RealmSwift

// MARK: - Protocol

protocol HomeScreenPresenterProtocol {
    func wireIn(
        sceneIsInitialized: ReactiveSwift.Property<Bool>, interactor: HomeScreenInteractorProtocol, view: HomeScreenViewProtocol,
        workerQueueScheduler: QueueScheduler)
    var requestSignal: Signal<HomeScreenPresenter.Request, NoError> { get }
}

// MARK: - Implementation

final class HomeScreenPresenter: HomeScreenPresenterProtocol, RequestEmitter {

    enum Request {
        case initView(isLoading: ReactiveSwift.Property<Bool>)
        case showMovies(movieViewModels: [NowPlayingMovieCollectionItemViewModel])
        case stopRefreshControlIfNeeded
    }

    private let isLoading = MutableProperty<Bool>(false)

    func wireIn(
        sceneIsInitialized: ReactiveSwift.Property<Bool>, interactor: HomeScreenInteractorProtocol, view: HomeScreenViewProtocol,
        workerQueueScheduler: QueueScheduler) {

        sceneIsInitialized.producer
            .observe(on: workerQueueScheduler)
            .filter { $0 }
            .startWithValues { [weak self] _ in
                guard let strongSelf = self else { return }
                strongSelf.requestEmitter.send(value: .initView(isLoading: ReactiveSwift.Property(strongSelf.isLoading)))
            }

        interactor.eventSignal
            .observe(on: workerQueueScheduler)
            .observeValues { [weak self] event in
                guard let strongSelf = self else { return }
                switch event {
                case .startedLoading:
                    strongSelf.isLoading.value = true
                case .endedLoading:
                    strongSelf.isLoading.value = false
                case .completedReloading:
                    strongSelf.requestEmitter.send(value: .stopRefreshControlIfNeeded)
                default: break
                }
            }

        interactor.requestSignal
            .observe(on: workerQueueScheduler)
            .observeValues { [weak self] request in
                guard let strongSelf = self else { return }
                switch request {
                case let .showMovies(movies):
                    let movieViewModels = movies.map { NowPlayingMovieCollectionItemViewModel(movie: $0) }
                    if movieViewModels.isNotEmpty {
                        strongSelf.requestEmitter.send(value: .showMovies(movieViewModels: movieViewModels))
                    }
                }
            }
    }

}
