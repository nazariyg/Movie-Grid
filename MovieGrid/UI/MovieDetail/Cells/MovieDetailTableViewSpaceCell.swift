// Copyright © 2019 Nazariy Gorpynyuk.
// All rights reserved.

import Foundation

import UIKit
import Cornerstones
import Cartography

final class MovieDetailTableViewSpaceCell: MovieDetailTableViewCell {

    private struct Constants {
        static let height = s(34)
    }

    private var spaceView: UIView!

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
        spaceView = UIView()
        contentView.addSubview(spaceView)
    }

    private func layout() {
        constrain(spaceView, contentView) { view, superview in
            view.edges == superview.edges
            view.height == Constants.height
        }
    }

}
