// Copyright © 2019 Nazariy Gorpynyuk.
// All rights reserved.

import Foundation
import Cornerstones
import Core
import ReactiveSwift
import Result
import RealmSwift

// MARK: - Protocol

protocol HomeScreenInteractorProtocol {
    func wireIn(
        sceneIsInitialized: ReactiveSwift.Property<Bool>, presenter: HomeScreenPresenterProtocol, view: HomeScreenViewProtocol,
        workerQueueScheduler: QueueScheduler)
    var requestSignal: Signal<HomeScreenInteractor.Request, NoError> { get }
    var eventSignal: Signal<HomeScreenInteractor.Event, NoError> { get }
}

// MARK: - Implementation

final class HomeScreenInteractor: HomeScreenInteractorProtocol, RequestEmitter, EventEmitter {

    enum Request {
        case showMovies([Movie])
    }

    enum Event {
        case startedLoading
        case endedLoading
        case completedReloading
        case selectedMovie(movieReference: ThreadSafeReference<Movie>, movieTitle: String?)
    }

    private let nowPlayingMoviesProvider =
        InstanceProvider.shared.instance(
            for: NowPlayingMoviesProviderProtocol.self, defaultInstance: NowPlayingMoviesProvider())  // for testability
    private var workerQueueScheduler: QueueScheduler!
    private var didInitiateLoading = false
    private var _movies: [ThreadSafeReference<Movie>] = []
    private var movies: [Movie] {
        get {
            let movies = _movies.compactMap { Store.default.resolve($0) }
            _movies = movies.map { ThreadSafeReference(to: $0) }
            return movies
        }
        set(movies) {
            _movies = movies.map { ThreadSafeReference(to: $0) }
        }
    }

    func wireIn(
        sceneIsInitialized: ReactiveSwift.Property<Bool>, presenter: HomeScreenPresenterProtocol, view: HomeScreenViewProtocol,
        workerQueueScheduler: QueueScheduler) {

        self.workerQueueScheduler = workerQueueScheduler

        view.eventSignal
            .observe(on: workerQueueScheduler)
            .observeValues { [weak self] event in
                guard let strongSelf = self else { return }
                switch event {
                case .scrolledToEnd:
                    strongSelf.nowPlayingMoviesProvider.loadNextMoviesPage()
                case .startedRefresh:
                    strongSelf.nowPlayingMoviesProvider.reloadMovies()
                case let .tappedMovie(movieID):
                    strongSelf.onSelectedMovie(movieID: movieID)
                }
            }

        wireInNowPlayingMoviesProvider()

        sceneIsInitialized.producer
            .observe(on: workerQueueScheduler)
            .filter { $0 }
            .startWithValues { [weak self] _ in
                guard let strongSelf = self else { return }
                if let isOnline = Network.shared.isOnline.value, isOnline {
                    strongSelf.didInitiateLoading = true
                    strongSelf.nowPlayingMoviesProvider.reloadMovies()
                } else {
                    strongSelf.nowPlayingMoviesProvider.loadStoredMovies()
                }
            }
    }

    private func wireInNowPlayingMoviesProvider() {
        nowPlayingMoviesProvider.isLoading.producer
            .observe(on: workerQueueScheduler)
            .startWithValues { [weak self] isLoading in
                guard let strongSelf = self else { return }
                if isLoading {
                    strongSelf.eventEmitter.send(value: .startedLoading)
                } else if strongSelf.didInitiateLoading {
                    strongSelf.eventEmitter.send(value: .endedLoading)
                }
            }

        nowPlayingMoviesProvider.movies.producer
            .observe(on: workerQueueScheduler)
            .startWithValues { [weak self] movies in
                guard let strongSelf = self else { return }
                let moviesToShow = movies.compactMap { Store.default.resolve($0) }
                guard moviesToShow.isNotEmpty else { return }
                strongSelf.movies = moviesToShow
                strongSelf.requestEmitter.send(value: .showMovies(moviesToShow))
            }

        nowPlayingMoviesProvider.eventSignal
            .observe(on: workerQueueScheduler)
            .observeValues { [weak self] event in
                guard let strongSelf = self else { return }
                switch event {
                case let .updatedMovies(updateType, success):
                    if updateType == .reload {
                        strongSelf.eventEmitter.send(value: .completedReloading)
                        if !success {
                            // Load movies from the persistent store in case we are offline.
                            strongSelf.nowPlayingMoviesProvider.loadStoredMovies()
                        }
                    }
                }
            }
    }

    private func onSelectedMovie(movieID: Int) {
        guard let movie = movies.first(where: { $0.id == movieID }) else { return }
        eventEmitter.send(value: .selectedMovie(movieReference: ThreadSafeReference(to: movie), movieTitle: movie.title))
    }

}
