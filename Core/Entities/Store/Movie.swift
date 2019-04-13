// Copyright © 2019 Nazariy Gorpynyuk.
// All rights reserved.

import Foundation
import RealmSwift

// Except for ID, all schema objects are optional per https://developers.themoviedb.org/3/movies/get-now-playing

@objcMembers
public final class Movie: Object {

    public dynamic var id = Int()
    public dynamic var posterPath: String?
    public dynamic var title: String?
    public dynamic var releaseDate: Date?
    public dynamic var overview: String?
    public let voteAverage = RealmOptional<Double>()

    // Ensure object uniqueness.
    public override static func primaryKey() -> String? {
        return #keyPath(id)
    }

}

public extension Movie {

    // MARK: - Lifecycle

    convenience init?(_ apiMovie: APIMovie) {
        self.init()
        guard let apiMovieID = apiMovie.id else { return nil }

        id = apiMovieID
        posterPath = apiMovie.posterPath
        title = apiMovie.title
        releaseDate = apiMovie.releaseDate
        overview = apiMovie.overview
        voteAverage.value = apiMovie.voteAverage
    }

    // MARK: - Updating

    func update(from movie: Movie) {
        posterPath = movie.posterPath
        title = movie.title
        releaseDate = movie.releaseDate
        overview = movie.overview
        voteAverage.value = movie.voteAverage.value
    }

    // MARK: - Poster URL

    enum PosterSize: String {
        case w92, w154, w185, w342, w500, w780, original
    }

    func posterURL(for posterSize: PosterSize) -> URL? {
        guard let posterPath = posterPath else { return nil }
        return
            Backend.imageBaseURL
                .appendingPathComponent("t")
                .appendingPathComponent("p")
                .appendingPathComponent(posterSize.rawValue)
                .appendingPathComponent(posterPath)
    }

}
