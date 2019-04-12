// Copyright © 2018 Nazariy Gorpynyuk.
// All rights reserved.

import UIKit

public extension UILabel {

    var kerning: CGFloat {
        get {
            guard let kernValue = attributedText?.attribute(.kern, at: 0, effectiveRange: nil) as? NSNumber else { return 0 }
            return CGFloat(kernValue.doubleValue)
        }
        set(value) {
            let string: String
            if let attributedText = attributedText {
                string = attributedText.string
            } else if let text = text {
                string = text
            } else {
                string = "\u{200b}"  // zero-width space
            }

            let attributedString = NSAttributedString(string: string, attributes: [.kern: value])
            attributedText = attributedString
        }
    }

    func boundingRect(forRange range: NSRange) -> CGRect? {
        guard let attributedText = attributedText else { return nil }
        let textStorage = NSTextStorage(attributedString: attributedText)
        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)
        let textContainer = NSTextContainer(size: bounds.size)
        textContainer.lineFragmentPadding = 0
        layoutManager.addTextContainer(textContainer)
        var glyphRange = NSRange()
        layoutManager.characterRange(forGlyphRange: range, actualGlyphRange: &glyphRange)
        return layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)
    }

}
