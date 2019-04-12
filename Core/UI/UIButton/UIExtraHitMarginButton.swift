// Copyright © 2019 Nazariy Gorpynyuk.
// All rights reserved.

import UIKit

public class UIExtraHitMarginButton: UIButtonBase {

    public var extraHitMargin: CGFloat = 0

    public override func point(inside point: CGPoint, with _: UIEvent?) -> Bool {
        let hitArea = bounds.insetBy(dx: -extraHitMargin, dy: -extraHitMargin)
        return hitArea.contains(point)
    }

}
