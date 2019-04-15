// Copyright © 2019 Nazariy Gorpynyuk.
// All rights reserved.

import Foundation

import UIKit
import Cornerstones
import Cartography

final class MovieDetailTableViewSeparatorCell: MovieDetailTableViewCell {

    private struct Constants {
        static let color = UIColor("#808080")
        static let height = s(1)
        static let leftMargin = s(24)
        static let rightMargin = s(0)
    }

    private var separatorView: UIView!

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

    // MARK: - Content

    private func fill() {
        separatorView = UIView()
        with(separatorView!) {
            $0.backgroundColor = Constants.color
            contentView.addSubview($0)
        }
    }

    private func layout() {
        constrain(separatorView, contentView) { view, superview in
            view.leading == superview.leading + Constants.leftMargin
            view.trailing == superview.trailing - Constants.rightMargin
            view.top == superview.top
            view.bottom == superview.bottom
            view.height == Constants.height
        }
    }

}
