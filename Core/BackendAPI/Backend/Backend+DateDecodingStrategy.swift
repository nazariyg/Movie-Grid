// Copyright © 2019 Nazariy Gorpynyuk.
// All rights reserved.

import Foundation

public extension Backend {

    static var dateDecodingStrategy: JSONDecoder.DateDecodingStrategy {
        return .custom({ decoder -> Date in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            let dateFormatter = ISO8601DateFormatter()
            if let date = dateFormatter.date(from: dateString) {
                return date
            }
            dateFormatter.formatOptions = [.withFullDate]
            if let date = dateFormatter.date(from: dateString) {
                return date
            }
            dateFormatter.formatOptions = [.withFullDate, .withFullTime]
            if let date = dateFormatter.date(from: dateString) {
                return date
            }
            dateFormatter.formatOptions = [.withInternetDateTime]
            if let date = dateFormatter.date(from: dateString) {
                return date
            }
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date string \(dateString)")
        })
    }

}
