// Copyright © 2019 Nazariy Gorpynyuk.
// All rights reserved.

import Foundation

// All schema objects are optional per https://developers.themoviedb.org/3/movies/get-now-playing

public struct APIMovie: Codable {

    public enum PosterSize: String {
        case w92, w154, w185, w342, w500, w780, original
    }

    public let id: Int?
    public let posterPath: String?
    public let title: String?
    public let releaseDate: Date?
    public let overview: String?
    public let voteAverage: Double?

    public func posterURL(for posterSize: PosterSize) -> URL? {
        guard let posterPath = posterPath else { return nil }
        return
            Backend.imageBaseURL
                .appendingPathComponent("t")
                .appendingPathComponent("p")
                .appendingPathComponent(posterSize.rawValue)
                .appendingPathComponent(posterPath)
    }

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case posterPath = "poster_path"
        case title = "title"
        case releaseDate = "release_date"
        case overview = "overview"
        case voteAverage = "vote_average"
    }

}
