// Copyright © 2019 Nazariy Gorpynyuk.
// All rights reserved.

import Foundation
import Cornerstones
import ReactiveSwift
import Result

// MARK: - Protocol

public protocol MovieDatabaseServiceProtocol {
    func requestingNowPlayingMovies(page: Int) -> SignalProducer<APIMoviesPage, CoreError>
}

// MARK: - Implementation

private let logCategory = "Movie Database Service"

public final class MovieDatabaseService: MovieDatabaseServiceProtocol {

    private let jsonDeserializationQueueScheduler: QueueScheduler = {
        let queueLabel = DispatchQueue.uniqueQueueLabel()
        return QueueScheduler(qos: .utility, name: queueLabel)
    }()

    // MARK: - Lifecycle

    public init() {}

    // MARK: - Requesting

    public func requestingNowPlayingMovies(page: Int) -> SignalProducer<APIMoviesPage, CoreError> {
        let endpoint = Backend.API.Movie.nowPlaying(page: page)
        let request = endpoint.request
        return
            BackendAPIRequester.making(request)
            .map { response -> Data in
                return response.payload
            }
            .flatMap(.latest) { [jsonDeserializationQueueScheduler, jsonDecoder] data -> SignalProducer<APIMoviesPage, CoreError> in
                return
                    SignalProducer(value: data)
                    .start(on: jsonDeserializationQueueScheduler)
                    .attemptMap { data -> Result<APIMoviesPage, CoreError> in
                        do {
                            let moviesPage = try jsonDecoder.decode(APIMoviesPage.self, from: data)
                            log.debug("Received \(moviesPage.results?.count ?? 0) movies", logCategory)
                            return .success(moviesPage)
                        } catch {
                            log.error("Could not deserialize a movie page data: \(error.localizedDescription)", logCategory)
                            return .failure(.apiEntityDeserializationError)
                        }
                    }
            }
    }

    // MARK: - Private

    private lazy var jsonDecoder: JSONDecoder = {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.dateDecodingStrategy = Backend.dateDecodingStrategy
        return jsonDecoder
    }()

}
