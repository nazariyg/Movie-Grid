// Copyright © 2019 Nazariy Gorpynyuk.
// All rights reserved.

import UIKit
import Cornerstones
import Core
import Cartography
import Kingfisher

final class NowPlayingMoviesCollectionViewCell: UICollectionViewCell {

    private struct Constants {
        static let backgroundColor = UIColor("#d0d0d0")
        static let cornerRadius = s(8)
    }

    private var posterImageView: UIImageView!
    private var posterUnavailableLabel: UIStyledLabel!
    private var button: UIButton!
    private var movie: NowPlayingMovieCollectionItemViewModel?
    private var onTapped: ((_ movieID: Int) -> Void)?

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
        contentView.backgroundColor = Constants.backgroundColor
        contentView.roundCorners(radius: Constants.cornerRadius)

        fill()
        layout()
    }

    // MARK: - Content

    private func fill() {
        posterImageView = UIImageView()
        with(posterImageView!) {
            $0.contentMode = .scaleAspectFill
            $0.kf.indicatorType = .activity
            contentView.addSubview($0)
        }

        posterUnavailableLabel = UIStyledLabel()
        with(posterUnavailableLabel!) {
            $0.text = "poster_unavailable".localized
            $0.numberOfLines = 0
            $0.textAlignment = .center
            $0.font = .mainMedium(16)
            contentView.addSubview($0)
        }

        button = UIButton()
        with(button!) {
            contentView.addSubview($0)

            $0.reactive
                .controlEvents(.touchUpInside)
                .observeValues { [weak self] _ in
                    guard
                        let strongSelf = self,
                        let movieID = strongSelf.movie?.movieID
                    else { return }
                    strongSelf.onTapped?(movieID)
                }
        }
    }

    private func layout() {
        constrain(posterImageView, contentView) { view, superview in
            view.edges == superview.edges
        }

        constrain(posterUnavailableLabel, contentView) { view, superview in
            view.center == superview.center
        }

        constrain(button, contentView) { view, superview in
            view.edges == superview.edges
        }
    }

    func update(movie: NowPlayingMovieCollectionItemViewModel, onTapped: @escaping (_ movieID: Int) -> Void) {
        self.movie = movie
        self.onTapped = onTapped
        let posterURL = movie.posterURL
        posterUnavailableLabel.isHidden = posterURL != nil
        if let posterURL = posterURL {
            posterImageView.kf.setImage(with: posterURL)
        } else {
            posterImageView.image = nil
        }
    }

}
