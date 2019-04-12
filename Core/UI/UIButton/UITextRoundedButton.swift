// Copyright © 2019 Nazariy Gorpynyuk.
// All rights reserved.

import UIKit
import Cornerstones

@IBDesignable
public final class UITextRoundedButton: UIExtraHitMarginButton {

    public static let defaultHorizontalPadding: CGFloat = 10
    public static let defaultVerticalPadding: CGFloat = 8
    public static let defaultCornerRadius: CGFloat = 10
    public static let defaultLineWidth: CGFloat = 1.5
    public static var backgroundAlpha: CGFloat = 0.1
    public static var pressedStateBackgroundAlpha: CGFloat = 0.33

    @IBInspectable var fillColor: UIColor? = Config.shared.appearance.defaultForegroundColor.withAlphaComponent(backgroundAlpha) {
        didSet {
            updateBackground()
        }
    }

    @IBInspectable var lineColor: UIColor = Config.shared.appearance.defaultForegroundColor {
        didSet {
            setNeedsDisplay()
        }
    }

    @IBInspectable private var horizontalPadding: CGFloat = defaultHorizontalPadding
    @IBInspectable private var verticalPadding: CGFloat = defaultVerticalPadding
    @IBInspectable private var cornerRadius: CGFloat = defaultCornerRadius
    @IBInspectable private var lineWidth: CGFloat = defaultLineWidth

    private var isPressed = false

    public init(
        horizontalPadding: CGFloat = defaultHorizontalPadding,
        verticalPadding: CGFloat = defaultVerticalPadding,
        cornerRadius: CGFloat = defaultCornerRadius,
        lineWidth: CGFloat = defaultLineWidth,
        lineColor: UIColor = Config.shared.appearance.defaultForegroundColor,
        fillColor: UIColor? = Config.shared.appearance.defaultForegroundColor.withAlphaComponent(backgroundAlpha)) {

        self.horizontalPadding = screenify(horizontalPadding)
        self.verticalPadding = screenify(verticalPadding)
        self.cornerRadius = screenify(cornerRadius)
        self.lineWidth = screenify(lineWidth)
        self.lineColor = lineColor
        self.fillColor = fillColor

        super.init(frame: .zero)
        commonInit()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        horizontalPadding = screenify(horizontalPadding)
        verticalPadding = screenify(verticalPadding)
        cornerRadius = screenify(cornerRadius)
        lineWidth = screenify(lineWidth)

        commonInit()
    }

    private func commonInit() {
        titleLabel?.font = .main(UIFont.buttonFontSize)
        setTitleColor(Config.shared.appearance.defaultForegroundColor, for: .normal)
        setTitleColor(Config.shared.appearance.defaultDisabledForegroundColor, for: .disabled)
        titleKerning = Config.shared.appearance.defaultFontKerning

        contentEdgeInsets = UIEdgeInsets(horizontalInset: horizontalPadding, verticalInset: verticalPadding)

        roundCorners(radius: cornerRadius)
        layer.borderWidth = lineWidth

        updateBackground()
        wireInTouchEvents()
    }

    private func wireInTouchEvents() {
        reactive.controlEvents(.touchDown).observeValues { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.isPressed = true
            strongSelf.updateBackground()
        }
        reactive.controlEvents([.touchUpInside, .touchUpOutside, .touchCancel]).observeValues { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.isPressed = false
            strongSelf.updateBackground()
        }
    }

    public override func draw(_ rect: CGRect) {
        if isEnabled {
            borderUIColor = lineColor

            if let attributedTitle = attributedTitle(for: .normal) {
                let attributedString = NSMutableAttributedString(attributedString: attributedTitle)
                attributedString.addAttribute(
                    .foregroundColor, value: Config.shared.appearance.defaultForegroundColor,
                    range: NSRange(location: 0, length: attributedString.length))
                setAttributedTitle(attributedString, for: .normal)
            }
        } else {
            borderUIColor = Config.shared.appearance.defaultDisabledLineColor

            if let attributedTitle = attributedTitle(for: .disabled) {
                let attributedString = NSMutableAttributedString(attributedString: attributedTitle)
                attributedString.addAttribute(
                    .foregroundColor, value: Config.shared.appearance.defaultDisabledForegroundColor,
                    range: NSRange(location: 0, length: attributedString.length))
                setAttributedTitle(attributedString, for: .disabled)
            }
        }
    }

    private func updateBackground() {
        if !isPressed {
            if let fillColor = fillColor {
                backgroundColor = fillColor
            } else {
                backgroundColor = nil
            }
        } else {
            if let fillColor = fillColor {
                if fillColor.alpha < 1 {
                    backgroundColor = fillColor.brighter(by: 0.1).withAlphaComponent(fillColor.alpha + 0.075)
                } else {
                    backgroundColor = fillColor.brighter(by: 0.1)
                }
            } else {
                backgroundColor = lineColor.withAlphaComponent(Self.pressedStateBackgroundAlpha)
            }
        }
    }

    private typealias `Self` = UITextRoundedButton

}
