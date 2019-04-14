// Copyright © 2019 Nazariy Gorpynyuk.
// All rights reserved.

import UIKit
import Cornerstones
import Cartography

final class NowPlayingMoviesCollectionViewLoadingIndicatorFooter: UICollectionReusableView {

    private var loadingIndicator: UIActivityIndicatorView!

    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    func commonInit() {
        fill()
        layout()
    }

    // MARK: - Content

    private func fill() {
        loadingIndicator = UIActivityIndicatorView(style: .gray)
        with(loadingIndicator!) {
            $0.transform = CGAffineTransform(scaleX: 2, y: 2)
            $0.startAnimating()
            addSubview($0)
        }
    }

    private func layout() {
        constrain(loadingIndicator, self) { view, superview in
            view.center == superview.center
        }
    }

}
