// Copyright © 2019 Nazariy Gorpynyuk.
// All rights reserved.

import UIKit
import Core

public final class NowPlayingMoviesCollectionView: UIStyledCollectionView {

    public init() {
        let collectionViewLayout = NowPlayingMoviesCollectionViewLayout()
        super.init(frame: .zero, collectionViewLayout: collectionViewLayout)
        commonInit()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        showsHorizontalScrollIndicator = false
    }

}
