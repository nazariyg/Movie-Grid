// Copyright © 2019 Nazariy Gorpynyuk.
// All rights reserved.

import UIKit

public class UIButtonBase: UIButton {

    public override func setTitle(_ title: String?, for state: UIControl.State) {
        super.setTitle(title, for: state)

        // Also set the attributed title if needed, preserving the style.
        if let attributedTitle = attributedTitle(for: state)?.mutableCopy() as? NSMutableAttributedString {
            guard let title = title else {
                setAttributedTitle(nil, for: state)
                return
            }
            attributedTitle.mutableString.setString(title)
            setAttributedTitle(attributedTitle, for: state)
        }
    }

}
