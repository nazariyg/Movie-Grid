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

    public override static func primaryKey() -> String? {
        return #keyPath(id)
    }

}

public extension Movie {

    enum PosterSize: String {
        case w92, w154, w185, w342, w500, w780, original
    }

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