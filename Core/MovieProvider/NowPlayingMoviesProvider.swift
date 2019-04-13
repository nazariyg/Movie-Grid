// Copyright © 2019 Nazariy Gorpynyuk.
// All rights reserved.

import Foundation
import Cornerstones
import ReactiveSwift
import Result
import RealmSwift

// MARK: - Protocol

public protocol NowPlayingMoviesProviderProtocol {
    var isLoading: ReactiveSwift.Property<Bool> { get }
    var movies: ReactiveSwift.Property<[ThreadSafeReference<Movie>]> { get }
    func reloadMovies()
    func loadNextMoviesPage()
    func loadStoredMovies()
    var eventSignal: Signal<NowPlayingMoviesProvider.Event, NoError> { get }
}

// MARK: - Implementation

public final class NowPlayingMoviesProvider: NowPlayingMoviesProviderProtocol, EventEmitter {

    public var isLoading: ReactiveSwift.Property<Bool> {
        return _isLoading.skipRepeats()
    }
    private let _isLoading = MutableProperty<Bool>(false)

    public var movies: ReactiveSwift.Property<[ThreadSafeReference<Movie>]> {
        return ReactiveSwift.Property(threadSafeMovies)
    }
    private let threadSafeMovies = MutableProperty<[ThreadSafeReference<Movie>]>([])
    private let _movies = MutableProperty<[Movie]>([])

    public enum UpdateType {
        case reload
        case loadNextPage
        case loadFromStore
    }

    public enum Event {
        case updatedMovies(updateType: UpdateType, success: Bool)
    }

    private let movieDatabaseService =
        InstanceProvider.shared.instance(
            for: MovieDatabaseServiceProtocol.self, defaultInstance: MovieDatabaseService())  // for testability
    private var moviesLastLoadedPage: Int?
    private var moviesTotalPages: Int?
    private var moviesLoadingDisposable: Disposable?

    // Processing queue.
    private let workerQueue = DispatchQueue.fileSpecificSerialQueue(qos: .utility)

    // MARK: - Lifecycle

    public init() {
        wireInForThreadSafeMovies()
    }

    // MARK: - Loading movies

    public func reloadMovies() {
        moviesLastLoadedPage = nil
        loadAPIMovies(forPage: Backend.paginationFirstPage, updateType: .reload)
    }

    public func loadNextMoviesPage() {
        guard let moviesLastLoadedPage = moviesLastLoadedPage else {
            reloadMovies()
            return
        }

        let nextPage = moviesLastLoadedPage + 1
        if let moviesTotalPages = moviesTotalPages,
           nextPage > moviesTotalPages {
            // We have already reached the last page.
            return
        }

        loadAPIMovies(forPage: nextPage, updateType: .loadNextPage)
    }

    public func loadStoredMovies() {
        _movies.value = orderedStoredMovies
        eventEmitter.send(value: .updatedMovies(updateType: .loadFromStore, success: true))
    }

    // MARK: - Private

    private var orderedStoredMovies: [Movie] {
        // Query movies from the persistent store, in the appropriate order.
        let orderedStoredMovies: [Movie] =
            Store.default.objects(NowPlayingMovieOrder.self)
            .sorted(byKeyPath: #keyPath(NowPlayingMovieOrder.orderIndex), ascending: true)
            .compactMap { Store.default.object(ofType: Movie.self, forPrimaryKey: $0.movieID) }
        return orderedStoredMovies
    }

    private func loadAPIMovies(forPage page: Int, updateType: UpdateType) {
        _isLoading.value = true
        moviesLoadingDisposable?.dispose()
        moviesLoadingDisposable =
            movieDatabaseService.requestingNowPlayingMovies(page: page)
            .take(duringLifetimeOf: self)
            .startWithResult { [weak self] result in
                guard let strongSelf = self else { return }
                strongSelf._isLoading.value = false

                switch result {
                case let .success(apiMoviesPage):
                    strongSelf.moviesLastLoadedPage = page
                    if let totalPages = apiMoviesPage.totalPages {
                        strongSelf.moviesTotalPages = totalPages
                    }
                    if let apiMovies = apiMoviesPage.results {
                        strongSelf.processReceivedAPIMovies(apiMovies, updateType: updateType)
                    }
                    strongSelf.eventEmitter.send(value: .updatedMovies(updateType: updateType, success: true))
                case let .failure(error):
                    strongSelf.handleError(error)
                    strongSelf.eventEmitter.send(value: .updatedMovies(updateType: updateType, success: false))
                }
            }
    }

    // MARK: - Processing

    private func processReceivedAPIMovies(_ apiMovies: [APIMovie], updateType: UpdateType) {
        workerQueue.executeAsync { [weak self] in
            guard let strongSelf = self else { return }

            var movies: [Movie]
            if updateType == .reload {
                Store.default.modify {
                    Store.default.delete(Store.default.objects(Movie.self))
                }
                movies = []
            } else {
                movies = strongSelf.orderedStoredMovies
            }

            Store.default.modify {
                apiMovies.forEach { apiMovie in
                    guard let movie = Movie(apiMovie) else { return }

                    // Store the movie or update a stored movie.
                    let movieIndex: Int
                    if let existingStoredMovieIndex = movies.firstIndex(where: { $0.id == movie.id }) {
                        // The API returned a movie that is already in the current list. Replace the old one.
                        let existingStoredMovie = movies[existingStoredMovieIndex]
                        existingStoredMovie.update(from: movie)
                        movieIndex = existingStoredMovieIndex
                    } else {
                        // The API returned a movie that is new to the current list. Supplement the new one.
                        Store.default.add(movie)
                        movieIndex = movies.count
                        movies.append(movie)
                    }

                    // The movie's display order.
                    if let existingStoredMovieOrder =
                        Store.default.object(ofType: NowPlayingMovieOrder.self, forPrimaryKey: movie.id) {
                        // Update.
                        existingStoredMovieOrder.orderIndex = movieIndex
                    } else {
                        // Add.
                        let movieOrder = NowPlayingMovieOrder(movieID: movie.id, orderIndex: movieIndex)
                        Store.default.add(movieOrder)
                    }
                }
            }

            // Notify observers.
            strongSelf._movies.value = movies
        }
    }

    private func wireInForThreadSafeMovies() {
        threadSafeMovies <~
            _movies.map { movies -> [ThreadSafeReference<Movie>] in
                return movies.map { ThreadSafeReference(to: $0) }
            }
    }

    // MARK: - Error handling

    private func handleError(_ error: CoreError) {
        ErrorManager.shared.handleError(error)
    }

}
