// Copyright © 2019 Nazariy Gorpynyuk.
// All rights reserved.

import UIKit
import Cornerstones
import Cartography
import Lottie
import ReactiveSwift
import Result

final class NowPlayingMoviesCollectionViewLoadingIndicatorFooter: UICollectionReusableView {

    private struct Constants {
        static let indicatorSide: CGFloat = s(64)
        static let indicatorAlpha: CGFloat = 0.25
        static let indicatorAppearanceAnimationDuration: TimeInterval = 0.2
    }

    private var loadingIndicator: AnimationView!
    private var isLoadingObserverDisposable: Disposable?
    private var isHiddenObserverDisposable: Disposable?

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
        loadingIndicator = AnimationView(name: "MovieLoadingIndicator", bundle: Bundle(for: type(of: self)))
        with(loadingIndicator!) {
            $0.loopMode = .loop
            $0.alpha = 0
            addSubview($0)
        }
    }

    private func layout() {
        constrain(loadingIndicator, self) { view, superview in
            view.center == superview.center
            view.width == Constants.indicatorSide
            view.height == view.width
        }
    }

    public func update(isLoading: ReactiveSwift.Property<Bool>, isHidden: ReactiveSwift.Property<Bool>) {
        isLoadingObserverDisposable?.dispose()
        isLoadingObserverDisposable =
            isLoading.producer
                .observe(on: UIScheduler())
                .startWithValues { [weak self] isLoading in
                    guard let strongSelf = self else { return }
                    if isLoading {
                        strongSelf.showIndicator()
                    } else {
                        strongSelf.hideIndicator()
                    }
                }

        isHiddenObserverDisposable?.dispose()
        isHiddenObserverDisposable =
            isHidden.producer
                .observe(on: UIScheduler())
                .startWithValues { [weak self] isHidden in
                    self?.loadingIndicator.isHidden = isHidden
                }
    }

    // MARK: - Loading indicator

    private func showIndicator() {
        if !loadingIndicator.isAnimationPlaying {
            loadingIndicator.play()
        }
        UIView.animate(
            withDuration: Constants.indicatorAppearanceAnimationDuration, delay: 0, options: .beginFromCurrentState,
            animations: { [weak self] in
            self?.loadingIndicator.alpha = Constants.indicatorAlpha
        })
    }

    private func hideIndicator() {
        UIView.animate(
            withDuration: Constants.indicatorAppearanceAnimationDuration, delay: 0, options: .beginFromCurrentState,
            animations: { [weak self] in
            self?.loadingIndicator.alpha = 0
        }, completion: { [weak self] isCompleted in
            guard isCompleted else { return }
            self?.loadingIndicator.stop()
        })
    }

}
