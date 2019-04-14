// Copyright © 2019 Nazariy Gorpynyuk.
// All rights reserved.

import UIKit
import Cornerstones

final class NowPlayingMoviesCollectionViewLayout: UICollectionViewFlowLayout {

    private struct Constants {
        static let topPadding: CGFloat = s(16)
        static let bottomPadding: CGFloat = s(0)
        static let horizontalPadding: CGFloat = s(16)
        static let horizontalSpacing: CGFloat = s(16)
        static let verticalSpacing: CGFloat = s(16)
        static let cellsPerRowPortrait: Int = 2
        static let cellsPerRowLandscape: Int = 4
        static let cellAspectRatio: CGFloat = 3/2
        static let footerHeight: CGFloat = s(160)
    }

    override func prepare() {
        super.prepare()
        guard let collectionView = collectionView else { return }

        let leftInset = max(Constants.horizontalPadding, collectionView.safeAreaInsets.left)
        let rightInset = max(Constants.horizontalPadding, collectionView.safeAreaInsets.right)
        let isLandscape = UIApplication.shared.statusBarOrientation.isLandscape
        let cellsPerRow = !isLandscape ? Constants.cellsPerRowPortrait : Constants.cellsPerRowLandscape
        let availableWidth = collectionView.bounds.width - (leftInset + rightInset)
        let cellWidth = (availableWidth - CGFloat(cellsPerRow - 1)*Constants.horizontalSpacing)/CGFloat(cellsPerRow)
        let cellHeight = cellWidth*Constants.cellAspectRatio

        itemSize = CGSize(width: cellWidth, height: cellHeight)
        sectionInset =
            UIEdgeInsets(
                top: Constants.topPadding,
                left: leftInset,
                bottom: Constants.bottomPadding,
                right: rightInset)
        minimumLineSpacing = Constants.verticalSpacing

        if collectionView.numberOfItems(inSection: 0) == 0 {
            footerReferenceSize = collectionView.bounds.insetBy(dx: 0, dy: collectionView.safeAreaInsets.top).size
        } else {
            footerReferenceSize = CGSize(width: collectionView.bounds.width, height: Constants.footerHeight)
        }
    }

}
