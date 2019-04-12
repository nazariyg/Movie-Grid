// Copyright © 2019 Nazariy Gorpynyuk.
// All rights reserved.

import Foundation
import CoreGraphics

public extension CGSize {

    var rect: CGRect {
        return CGRect(origin: .zero, size: self)
    }

}
