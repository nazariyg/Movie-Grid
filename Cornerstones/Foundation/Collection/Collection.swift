// Copyright © 2018 Nazariy Gorpynyuk.
// All rights reserved.

import Foundation
import CoreLocation

public extension Collection {

    var isNotEmpty: Bool {
        return !isEmpty
    }

    var lastIndex: Index {
        return index(endIndex, offsetBy: -1)
    }

    subscript(safe index: Index) -> Element? {
        return startIndex <= index && index < endIndex ? self[index] : nil
    }

}

public extension MutableCollection {

    subscript(safe index: Index) -> Element? {
        get {
            return startIndex <= index && index < endIndex ? self[index] : nil
        }
        set(element) {
            if let element = element {
                if startIndex <= index && index < endIndex {
                    self[index] = element
                }
            }
        }
    }

}

public extension Collection where Element == Double {

    var location: CLLocationCoordinate2D {
        let index0 = startIndex
        let index1 = index(startIndex, offsetBy: 1)
        return CLLocationCoordinate2D(latitude: self[index0], longitude: self[index1])
    }

}
