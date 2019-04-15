// Copyright © 2019 Nazariy Gorpynyuk.
// All rights reserved.

import Foundation

import UIKit
import Cornerstones
import Core
import Cartography

final class MovieDetailTableViewHeaderCell: MovieDetailTableViewCell {

    private struct Constants {
        static let horizontalPadding = s(24)
        static let posterWidthRatio: CGFloat = 0.45
        static let posterAspectRatio: CGFloat = 3/2
        static let foregroundColor = UIColor.white
        static let landscapePointSizeMultiplier: CGFloat = 2
        static let labelTextFont: UIFont = .main(19)
        static let valueTextFont: UIFont = .mainMedium(22)
        static let posterTextMargin = s(24)
        static let textEntryDistance = s(80)
    }

    private var posterImageView: UIImageView!
    private var posterUnavailableLabel: UIStyledLabel!
    private var voteAverageLabel: UIStyledLabel!
    private var voteAverageValueLabel: UIStyledLabel!
    private var releaseDateLabel: UIStyledLabel!
    private var releaseDateValueLabel: UIStyledLabel!

    private var posterTextMarginConstraint: NSLayoutConstraint!
    private var textEntryDistanceConstraints: [NSLayoutConstraint] = []

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
        posterImageView = UIImageView()
        with(posterImageView!) {
            $0.contentMode = .scaleAspectFill
            $0.backgroundColor = UIColor("#d0d0d0")
            $0.roundCorners(radius: s(8))
            contentView.addSubview($0)
        }

        posterUnavailableLabel = UIStyledLabel()
        with(posterUnavailableLabel!) {
            $0.text = "poster_unavailable".localized
            $0.numberOfLines = 0
            $0.textAlignment = .center
            $0.font = .mainMedium(18)
            contentView.addSubview($0)
        }

        voteAverageLabel = UIStyledLabel()
        with(voteAverageLabel!) {
            $0.text = "\("vote_average_label".localized):"
            $0.font = Constants.labelTextFont
            $0.textColor = Constants.foregroundColor
            $0.adjustsFontSizeToFitWidth = true
            $0.minimumScaleFactor = 0.5
            contentView.addSubview($0)
        }

        voteAverageValueLabel = UIStyledLabel()
        with(voteAverageValueLabel!) {
            $0.font = Constants.valueTextFont
            $0.textColor = Constants.foregroundColor
            $0.adjustsFontSizeToFitWidth = true
            $0.minimumScaleFactor = 0.5
            contentView.addSubview($0)
        }

        releaseDateLabel = UIStyledLabel()
        with(releaseDateLabel!) {
            $0.text = "\("release_date_label".localized):"
            $0.font = Constants.labelTextFont
            $0.textColor = Constants.foregroundColor
            $0.adjustsFontSizeToFitWidth = true
            $0.minimumScaleFactor = 0.5
            contentView.addSubview($0)
        }

        releaseDateValueLabel = UIStyledLabel()
        with(releaseDateValueLabel!) {
            $0.font = Constants.valueTextFont
            $0.textColor = Constants.foregroundColor
            $0.adjustsFontSizeToFitWidth = true
            $0.minimumScaleFactor = 0.5
            contentView.addSubview($0)
        }
    }

    private func layout() {
        constrain(posterImageView, contentView) { view, superview in
            view.top == superview.top
            view.bottom == superview.bottom
            view.leading == superview.leading + Constants.horizontalPadding
            view.width == superview.width*Constants.posterWidthRatio
            view.height == view.width*Constants.posterAspectRatio ~ UILayoutPriority.defaultHigh
        }

        constrain(posterUnavailableLabel, posterImageView) { view, reference in
            view.center == reference.center
        }

        constrain(voteAverageLabel, posterImageView, contentView) { view, poster, superview in
            posterTextMarginConstraint = view.leading == poster.trailing + Constants.posterTextMargin
            view.trailing == superview.trailing - Constants.horizontalPadding
            view.top == poster.top + s(8)
        }

        constrain(voteAverageValueLabel, voteAverageLabel) { view, reference in
            view.leading == reference.leading
            view.trailing == reference.trailing
            view.top == reference.bottom
        }

        constrain(releaseDateLabel, voteAverageLabel) { view, reference in
            view.leading == reference.leading
            view.trailing == reference.trailing
            textEntryDistanceConstraints.append(view.top == reference.top + Constants.textEntryDistance)
        }

        constrain(releaseDateValueLabel, releaseDateLabel) { view, reference in
            view.leading == reference.leading
            view.trailing == reference.trailing
            view.top == reference.bottom
        }
    }

    public func update(posterURL: URL?, voteAverage: Double?, releaseDate: Date?) {
        posterImageView.kf.setImage(with: posterURL)
        posterUnavailableLabel.isHidden = posterURL != nil

        if let voteAverage = voteAverage {
            voteAverageValueLabel.isHidden = false
            voteAverageValueLabel.text = String(voteAverage)
        } else {
            voteAverageValueLabel.isHidden = true
        }

        if let releaseDate = releaseDate {
            releaseDateValueLabel.isHidden = false
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            releaseDateValueLabel.text = formatter.string(from: releaseDate)
        } else {
            releaseDateValueLabel.isHidden = true
        }
    }

    private func adjustContentForCurrentOrientation() {
        let isLandscape = UIApplication.shared.statusBarOrientation.isLandscape

        if !isLandscape {
            posterTextMarginConstraint.constant = Constants.posterTextMargin
            voteAverageLabel.font = Constants.labelTextFont
            voteAverageValueLabel.font = Constants.valueTextFont
            releaseDateLabel.font = Constants.labelTextFont
            releaseDateValueLabel.font = Constants.valueTextFont
            textEntryDistanceConstraints.forEach { $0.constant = Constants.textEntryDistance }

        } else {
            posterTextMarginConstraint.constant = Constants.posterTextMargin*Constants.landscapePointSizeMultiplier
            voteAverageLabel.font = Constants.labelTextFont.withSize(Constants.labelTextFont.pointSize*Constants.landscapePointSizeMultiplier)
            voteAverageValueLabel.font = Constants.valueTextFont.withSize(Constants.valueTextFont.pointSize*Constants.landscapePointSizeMultiplier)
            releaseDateLabel.font = Constants.labelTextFont.withSize(Constants.labelTextFont.pointSize*Constants.landscapePointSizeMultiplier)
            releaseDateValueLabel.font = Constants.valueTextFont.withSize(Constants.valueTextFont.pointSize*Constants.landscapePointSizeMultiplier)
            textEntryDistanceConstraints.forEach { $0.constant = Constants.textEntryDistance*Constants.landscapePointSizeMultiplier }
        }
    }

}
