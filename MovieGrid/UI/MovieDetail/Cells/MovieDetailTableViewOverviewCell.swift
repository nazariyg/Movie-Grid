// Copyright © 2019 Nazariy Gorpynyuk.
// All rights reserved.

import Foundation

import UIKit
import Cornerstones
import Core
import Cartography

final class MovieDetailTableViewOverviewCell: MovieDetailTableViewCell {

    private struct Constants {
        static let font: UIFont = .mainMedium(17)
        static let color: UIColor = .white
        static let horizontalPadding: CGFloat = s(24)
        static let landscapePointSizeMultiplier: CGFloat = 1.5
    }

    private var overviewLabel: UIStyledLabel!

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
        overviewLabel = UIStyledLabel()
        with(overviewLabel!) {
            $0.font = Constants.font
            $0.textColor = Constants.color
            $0.numberOfLines = 0
            contentView.addSubview($0)
        }
    }

    private func layout() {
        constrain(overviewLabel, contentView) { view, superview in
            view.leading == superview.leading + Constants.horizontalPadding
            view.trailing == superview.trailing - Constants.horizontalPadding
            view.top == superview.top
            view.bottom == superview.bottom
        }
    }

    public func update(overview: String?) {
        overviewLabel.text = overview
    }

    private func adjustContentForCurrentOrientation() {
        let isLandscape = UIApplication.shared.statusBarOrientation.isLandscape
        if !isLandscape {
            overviewLabel.font = Constants.font
        } else {
            overviewLabel.font = Constants.font.withSize(Constants.font.pointSize*Constants.landscapePointSizeMultiplier)
        }
    }

}
