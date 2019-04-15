// Copyright © 2019 Nazariy Gorpynyuk.
// All rights reserved.

import Foundation
import Core

struct MovieDetailViewModel {

    private struct Constants {
        static let posterSize: Movie.PosterSize = .w342
    }

    let movieID: Int
    let posterURL: URL?
    let title: String?
    let releaseDate: Date?
    let overview: String?
    let voteAverage: Double?

    init(movie: Movie) {
        movieID = movie.id
        posterURL = movie.posterURL(for: Constants.posterSize)
        title = movie.title
        releaseDate = movie.releaseDate
        overview = movie.overview
        voteAverage = movie.voteAverage.value
    }

}
