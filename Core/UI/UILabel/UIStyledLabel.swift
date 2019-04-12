// Copyright © 2019 Nazariy Gorpynyuk.
// All rights reserved.

import UIKit
import Cornerstones

public class UIStyledLabel: UILabelBase {

    public init() {
        super.init(frame: .zero)
        commonInit()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        font = .main(UIFont.labelFontSize)
        textColor = Config.shared.appearance.defaultForegroundColor
        kerning = Config.shared.appearance.defaultFontKerning
    }

}
