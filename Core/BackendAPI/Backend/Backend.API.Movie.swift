// Copyright © 2019 Nazariy Gorpynyuk.
// All rights reserved.

import Foundation
import Cornerstones

public extension Backend.API.Movie {

    var request: HTTPRequest {

        switch self {

        case let .nowPlaying(page):
            return HTTPRequest(
                url: url,
                parameters: requestParameters(for: [
                    Backend.ParameterKey.page: page
                ]))

        }

    }

}
