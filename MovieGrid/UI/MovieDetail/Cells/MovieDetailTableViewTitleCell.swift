// Copyright © 2019 Nazariy Gorpynyuk.
// All rights reserved.

import Foundation

import UIKit
import Cornerstones
import Core
import Cartography

final class MovieDetailTableViewTitleCell: MovieDetailTableViewCell {

    private struct Constants {
        static let maxHeight = s(160)
        static let font: UIFont = .mainMedium(42)
        static let color: UIColor = .white
        static let horizontalPadding = s(24)
        static let landscapePointSizeMultiplier: CGFloat = 1.5
    }

    private var titleLabel: UIStyledLabel!

    // MARK: - Lifecycle

    override init(style: CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        fill()
        layout()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        adjustContentForCurrentOrientation()
    }

    // MARK: - Content

    private func fill() {
        titleLabel = UIStyledLabel()
        with(titleLabel!) {
            $0.font = Constants.font
            $0.textColor = Constants.color
            $0.numberOfLines = 0
            $0.textAlignment = .center
            $0.kerning = 1.5
            $0.adjustsFontSizeToFitWidth = true
            $0.minimumScaleFactor = 0.5
            contentView.addSubview($0)
        }
    }

    private func layout() {
        constrain(titleLabel, contentView) { view, superview in
            view.leading == superview.leading + Constants.horizontalPadding
            view.trailing == superview.trailing - Constants.horizontalPadding
            view.top == superview.top
            view.bottom == superview.bottom
            view.height <= Constants.maxHeight
        }
    }

    public func update(title: String?) {
        titleLabel.text = title
    }

    private func adjustContentForCurrentOrientation() {
        let isLandscape = UIApplication.shared.statusBarOrientation.isLandscape
        if !isLandscape {
            titleLabel.font = Constants.font
        } else {
            titleLabel.font = Constants.font.withSize(Constants.font.pointSize*Constants.landscapePointSizeMultiplier)
        }
    }

}
