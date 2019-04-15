// Copyright © 2019 Nazariy Gorpynyuk.
// All rights reserved.

import Foundation

import UIKit

class MovieDetailTableViewCell: UITableViewCell {

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
        selectionStyle = .none
        backgroundColor = .clear
    }

}
