// Copyright © 2019 Nazariy Gorpynyuk.
// All rights reserved.

import UIKit

public class UIPassthroughView: UIView {

    public override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return subviews.contains {
            !$0.isHidden && $0.point(inside: convert(point, to: $0), with: event)
        }
    }

}
