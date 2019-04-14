// Copyright © 2019 Nazariy Gorpynyuk.
// All rights reserved.

import Foundation
import Core
import DeepDiff

struct NowPlayingMovieCollectionItemViewModel {

    private struct Constants {
        static let posterSize: Movie.PosterSize = .w342
    }

    let movieID: Int
    let posterURL: URL?

    init(movie: Movie) {
        movieID = movie.id
        posterURL = movie.posterURL(for: Constants.posterSize)
    }

}

// To compute the difference between two collections of view models.
extension NowPlayingMovieCollectionItemViewModel: DiffAware {

    var diffId: Int {
        return movieID
    }

    static func compareContent(_ a: NowPlayingMovieCollectionItemViewModel, _ b: NowPlayingMovieCollectionItemViewModel) -> Bool {
        return a.movieID == b.movieID
    }

}
