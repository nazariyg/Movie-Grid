// Copyright © 2019 Nazariy Gorpynyuk.
// All rights reserved.

import Foundation
import Cornerstones
import Core
import ReactiveSwift
import Result
import ReactiveCocoa

// MARK: - Protocol

protocol MovieDetailPresenterProtocol {
    func wireIn(
        sceneIsInitialized: Property<Bool>, interactor: MovieDetailInteractorProtocol, view: MovieDetailViewProtocol, workerQueueScheduler: QueueScheduler)
    var requestSignal: Signal<MovieDetailPresenter.Request, NoError> { get }
}

// MARK: - Implementation

enum MovieDetailTableRowViewModel {
    case space
    case separator
    case header(posterURL: URL?, voteAverage: Double?, releaseDate: Date?)
    case title(text: String?)
    case overview(text: String?)
}

final class MovieDetailPresenter: MovieDetailPresenterProtocol, RequestEmitter {

    enum Request {
        case fillContent(movieViewModel: MovieDetailViewModel, tableRowViewModels: [MovieDetailTableRowViewModel])
    }

    private static func tableRowViewModels(for movieViewModel: MovieDetailViewModel) -> [MovieDetailTableRowViewModel] {
        return [
            .space,
            .header(posterURL: movieViewModel.posterURL, voteAverage: movieViewModel.voteAverage, releaseDate: movieViewModel.releaseDate),
            .space,
            .title(text: movieViewModel.title),
            .space,
            .separator,
            .space,
            .overview(text: movieViewModel.overview),
            .space,
            .separator,
            .space
        ]
    }

    func wireIn(
        sceneIsInitialized: Property<Bool>, interactor: MovieDetailInteractorProtocol, view: MovieDetailViewProtocol, workerQueueScheduler: QueueScheduler) {

        interactor.requestSignal
            .observe(on: workerQueueScheduler)
            .observeValues { [weak self] request in
                guard let strongSelf = self else { return }
                switch request {
                case let .fillContent(movieReference):
                    guard let movie = Store.default.resolve(movieReference) else { break }
                    let movieViewModel = MovieDetailViewModel(movie: movie)
                    strongSelf.requestEmitter.send(
                        value: .fillContent(
                            movieViewModel: movieViewModel,
                            tableRowViewModels: MovieDetailPresenter.tableRowViewModels(for: movieViewModel)))
                }
            }
    }

}
