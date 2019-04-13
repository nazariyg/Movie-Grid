// Copyright © 2019 Nazariy Gorpynyuk.
// All rights reserved.

import Foundation
import RealmSwift

// Lets restore the display order when launched in offline.

@objcMembers
public final class NowPlayingMovieOrder: Object {

    public dynamic var movieID = Int()
    public dynamic var orderIndex = Int()

    // Ensure object uniqueness.
    public override static func primaryKey() -> String? {
        return #keyPath(movieID)
    }

}

public extension NowPlayingMovieOrder {

    // MARK: - Lifecycle

    convenience init(movieID: Int, orderIndex: Int) {
        self.init()
        self.movieID = movieID
        self.orderIndex = orderIndex
    }

}
