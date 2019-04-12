// Copyright © 2019 Nazariy Gorpynyuk.
// All rights reserved.

import Foundation

// All schema objects are optional per https://developers.themoviedb.org/3/movies/get-now-playing

public struct APIMoviesPage: Codable {

    public let page: Int?
    public let results: [APIMovie]?
    public let totalPages: Int?
    public let totalResults: Int?

    enum CodingKeys: String, CodingKey {
        case page = "page"
        case results = "results"
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }

}
